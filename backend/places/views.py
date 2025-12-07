from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Place
import math


def calculate_distance(lat1, lon1, lat2, lon2):
    """두 좌표 사이의 거리를 계산 (km 단위)"""
    R = 6371  # 지구 반지름 (km)

    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)

    a = math.sin(delta_lat / 2) ** 2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    distance = R * c
    return round(distance, 2)


@api_view(['GET'])
def nearby_places(request):
    """주변 장소를 조회하는 API"""
    try:
        lat = float(request.GET.get('lat', 0))
        lon = float(request.GET.get('lon', 0))
        limit = int(request.GET.get('limit', 5))

        if lat == 0 or lon == 0:
            return Response({'error': '위도(lat)와 경도(lon)를 제공해주세요.'}, status=400)

        # 좌표가 있는 모든 장소 가져오기
        places = Place.objects.exclude(latitude__isnull=True).exclude(longitude__isnull=True)

        # 거리 계산 및 중복 제거
        seen_locations = set()
        places_with_distance = []

        for place in places:
            # 같은 좌표를 가진 장소는 하나만 표시 (중복 제거)
            location_key = (place.latitude, place.longitude)
            if location_key in seen_locations:
                continue
            seen_locations.add(location_key)

            distance = calculate_distance(lat, lon, place.latitude, place.longitude)
            places_with_distance.append({
                'id': place.id,
                'name': place.name,
                'address': place.address,
                'lat': place.latitude,
                'lon': place.longitude,
                'distance': distance,
                'contact': place.contact,
                'facilities': place.facilities
            })

        # 거리순으로 정렬
        places_with_distance.sort(key=lambda x: x['distance'])

        # limit 적용
        result = places_with_distance[:limit]

        return Response(result)

    except ValueError:
        return Response({'error': '잘못된 파라미터 형식입니다.'}, status=400)
    except Exception as e:
        return Response({'error': str(e)}, status=500)
