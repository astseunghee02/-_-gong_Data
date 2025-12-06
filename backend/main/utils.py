import math
import requests

def calculate_distance(lat1, lon1, lat2, lon2):
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