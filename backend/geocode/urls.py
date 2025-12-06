from django.urls import path
from .views import GeocodeView

urlpatterns = [
    path("", GeocodeView.as_view(), name="geocode"),
]