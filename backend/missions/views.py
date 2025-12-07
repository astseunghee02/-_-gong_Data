from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from .models import Mission, UserMission
from .serializers import MissionSerializer, UserMissionSerializer
from places.models import Place
from places.views import calculate_distance
import math


class GenerateMissionsView(APIView):
    """주변 장소 기반으로 미션 자동 생성"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        lat = float(request.data.get('lat', 0))
        lon = float(request.data.get('lon', 0))

        if lat == 0 or lon == 0:
            return Response({'error': '위치 정보가 필요합니다.'}, status=400)

        # 좌표가 있는 모든 장소 가져오기
        places = Place.objects.exclude(latitude__isnull=True).exclude(longitude__isnull=True)

        created_count = 0
        for place in places[:20]:  # 최대 20개 장소
            distance = calculate_distance(lat, lon, place.latitude, place.longitude)

            # 거리에 따른 난이도 결정
            if distance < 2:
                difficulty = 'easy'
            elif distance < 5:
                difficulty = 'normal'
            else:
                difficulty = 'hard'

            # 점수 계산
            points_info = Mission.calculate_points(distance, difficulty)

            # 미션이 이미 존재하는지 확인
            mission, created = Mission.objects.get_or_create(
                place=place,
                defaults={
                    'title': f'{place.name} 방문하기',
                    'description': f'{place.address}에 위치한 {place.name}을 방문하세요!',
                    'difficulty': difficulty,
                    'base_points': points_info['base_points'],
                    'distance_bonus': points_info['distance_bonus'],
                    'difficulty_bonus': points_info['difficulty_bonus'],
                }
            )

            if created:
                created_count += 1

                # 사용자의 미션 목록에 추가
                UserMission.objects.get_or_create(
                    user=request.user,
                    mission=mission,
                    defaults={'distance_from_user': distance}
                )

        return Response({
            'message': f'{created_count}개의 새로운 미션이 생성되었습니다.',
            'total_missions': Mission.objects.filter(is_active=True).count()
        })


class AvailableMissionsView(APIView):
    """도전 가능한 미션 목록"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_missions = UserMission.objects.filter(
            user=request.user,
            status='available',
            mission__is_active=True
        )
        serializer = UserMissionSerializer(user_missions, many=True)
        return Response(serializer.data)


class OngoingMissionsView(APIView):
    """진행중인 미션 목록"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_missions = UserMission.objects.filter(
            user=request.user,
            status='ongoing'
        )
        serializer = UserMissionSerializer(user_missions, many=True)
        return Response(serializer.data)


class StartMissionView(APIView):
    """미션 시작"""
    permission_classes = [IsAuthenticated]

    def post(self, request, mission_id):
        try:
            user_mission = UserMission.objects.get(
                user=request.user,
                mission_id=mission_id,
                status='available'
            )

            lat = float(request.data.get('lat', 0))
            lon = float(request.data.get('lon', 0))

            if lat and lon:
                distance = calculate_distance(
                    lat, lon,
                    user_mission.mission.place.latitude,
                    user_mission.mission.place.longitude
                )
                user_mission.start_mission(distance)
            else:
                user_mission.start_mission(0)

            serializer = UserMissionSerializer(user_mission)
            return Response(serializer.data)

        except UserMission.DoesNotExist:
            return Response({'error': '미션을 찾을 수 없습니다.'}, status=404)


class CompleteMissionView(APIView):
    """미션 완료"""
    permission_classes = [IsAuthenticated]

    def post(self, request, mission_id):
        try:
            user_mission = UserMission.objects.get(
                user=request.user,
                mission_id=mission_id,
                status='ongoing'
            )

            # 현재 위치와 목표 장소의 거리 확인 (100m 이내)
            lat = float(request.data.get('lat', 0))
            lon = float(request.data.get('lon', 0))

            if lat and lon:
                distance = calculate_distance(
                    lat, lon,
                    user_mission.mission.place.latitude,
                    user_mission.mission.place.longitude
                )

                # 100m 이내에 있어야 완료 가능
                if distance > 0.1:
                    return Response({
                        'error': f'목표 장소에서 {distance:.2f}km 떨어져 있습니다. 더 가까이 가주세요.',
                        'distance': distance
                    }, status=400)

            success = user_mission.complete_mission()
            if success:
                serializer = UserMissionSerializer(user_mission)
                return Response({
                    'message': '미션 완료!',
                    'points_earned': user_mission.points_earned,
                    'mission': serializer.data
                })
            else:
                return Response({'error': '미션을 완료할 수 없습니다.'}, status=400)

        except UserMission.DoesNotExist:
            return Response({'error': '진행중인 미션을 찾을 수 없습니다.'}, status=404)


class MissionStatsView(APIView):
    """미션 통계"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        stats = UserMission.get_user_stats(request.user)
        return Response(stats)
