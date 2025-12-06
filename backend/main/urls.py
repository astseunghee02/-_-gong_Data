from django.urls import path
from .views import NearbyEquipmentAPI

urlpatterns = [
    path('nearby/', NearbyEquipmentAPI.as_view()),
]