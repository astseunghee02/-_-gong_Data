from rest_framework.views import APIView
from rest_framework.response import Response
from .models import OutdoorEquipment
from .serializers import OutdoorEquipmentSerializer
from .utils import calculate_distance

class NearbyEquipmentAPI(APIView):
    def get(self, request):
        user_lat = float(request.GET.get("lat"))
        user_lon = float(request.GET.get("lon"))
        radius = float(request.GET.get("radius", 2))  # 기본 반경 2km

        equips = OutdoorEquipment.objects.all()

        result = []

        for eq in equips:
            dist = calculate_distance(
                user_lat, user_lon,
                eq.latitude, eq.longitude
            )

            if dist <= radius:
                result.append({
                    "name": eq.name,
                    "lat": eq.latitude,
                    "lon": eq.longitude,
                    "address": eq.address,
                    "distance": round(dist, 3)
                })

        result = sorted(result, key=lambda x: x["distance"])

        return Response(result)