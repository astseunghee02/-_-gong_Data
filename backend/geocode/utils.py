import requests
from django.conf import settings

def geocode_address(address):
    url = "https://dapi.kakao.com/v2/local/search/address.json"
    headers = {"Authorization": f"KakaoAK {settings.KAKAO_API_KEY}"}

    res = requests.get(url, headers=headers, params={"query": address})

    # HTTP 상태 코드 체크
    if res.status_code != 200:
        print(f"API 에러 (status {res.status_code}): {res.text}")
        return None, None

    data = res.json()

    if data.get("meta", {}).get("total_count", 0) == 0:
        return None, None

    doc = data["documents"][0]
    return float(doc["y"]), float(doc["x"])