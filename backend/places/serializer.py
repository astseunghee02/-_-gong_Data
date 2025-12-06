from rest_framework import serializers
from .models import Place
from geocode.utils import geocode_address


class PlaceSerializer(serializers.ModelSerializer):
    latitude = serializers.SerializerMethodField()
    longitude = serializers.SerializerMethodField()

    class Meta:
        model = Place
        fields = ['id', 'name', 'address', 'latitude', 'longitude']

    def get_latitude(self, obj):
        lat, lng = geocode_address(obj.address)
        return lat

    def get_longitude(self, obj):
        lat, lng = geocode_address(obj.address)
        return lng