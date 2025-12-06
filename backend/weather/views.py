import requests
from django.http import JsonResponse
from django.conf import settings

def get_weather(request):
    lat = request.GET.get('lat')
    lon = request.GET.get('lon')

    # 파라미터 체크
    if not lat or not lon:
        return JsonResponse({"error": "lat and lon are required"}, status=400)

    api_key = settings.OPENWEATHER_API_KEY
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={api_key}&units=metric"

    result = requests.get(url).json()
    return JsonResponse(result)
