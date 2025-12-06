import math
import requests
from math import radians, sin, cos, asin, sqrt


def calculate_distance(lat1, lon1, lat2, lon2):
    """
    기존 거리 계산 (km). 하버사인과 동일한 계산이지만 남겨둔다.
    """
    R = 6371  # km

    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)

    a = (
        math.sin(d_lat / 2) ** 2 +
        math.cos(math.radians(lat1)) *
        math.cos(math.radians(lat2)) *
        math.sin(d_lon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c


def haversine(lat1, lon1, lat2, lon2):
    """
    두 좌표(위도/경도) 사이의 거리(km)를 반환.
    """
    R = 6371  # km

    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
    c = 2 * asin(sqrt(a))
    return R * c

def fetch_equipment_data():
    url = "https://api.odcloud.kr/api/15037957/v1/uddi:7994f41a-bd52-4fc1-a684-a2f37b45cd60"

    params = {
        "serviceKey": "7bfd298f805bb64a62209ad0201852f850e8b53a92a1d75f58274dc68fd0c015",
        "page": 1,
        "perPage": 1000,
        "returnType": "JSON"
    }

    response = requests.get(url, params=params)
    return response.json()
