from rest_framework.views import APIView
from rest_framework.response import Response
from .models import OutdoorEquipment
from .utils import haversine

class NearbyEquipmentAPI(APIView):
    def get(self, request):
        """
        현재 위치 기준으로 가장 가까운 장비를 distance 오름차순으로 반환한다.
        쿼리 파라미터:
          - lat, lon: 필수. 사용자 위도/경도.
          - limit: 선택. 반환 개수. 기본 5.
        """
        user_lat = float(request.GET.get("lat"))
        user_lon = float(request.GET.get("lon"))
        limit = int(request.GET.get("limit", 5))

        equips = OutdoorEquipment.objects.exclude(
            latitude__isnull=True, longitude__isnull=True
        )

        results = []
        for eq in equips:
            dist = haversine(user_lat, user_lon, eq.latitude, eq.longitude)
            results.append({
                "id": eq.id,
                "name": eq.name,
                "lat": eq.latitude,
                "lon": eq.longitude,
                "address": eq.address,
                "distance": round(dist, 3),
            })

        results = sorted(results, key=lambda x: x["distance"])[:limit]

        return Response(results)
