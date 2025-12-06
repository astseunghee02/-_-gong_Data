import requests
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status


class GeocodeView(APIView):
    def post(self, request):
        address = request.data.get("address")

        if not address:
            return Response({"error": "address 필드가 필요합니다."}, status=400)

        url = "https://dapi.kakao.com/v2/local/search/address.json"
        headers = {"Authorization": f"KakaoAK {settings.KAKAO_API_KEY}"}
        params = {"query": address}

        res = requests.get(url, headers=headers, params=params)

        if res.status_code != 200:
            return Response({"error": "카카오 API 요청 실패"}, status=500)

        data = res.json()

        if data["meta"]["total_count"] == 0:
            return Response({"error": "해당 주소를 찾을 수 없습니다."}, status=404)

        # 첫 번째 결과 사용
        info = data["documents"][0]
        latitude = info["y"]
        longitude = info["x"]

        return Response({
            "address": address,
            "latitude": latitude,
            "longitude": longitude
        })