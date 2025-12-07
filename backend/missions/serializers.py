from rest_framework import serializers
from .models import Mission, UserMission
from places.serializer import PlaceSerializer


class MissionSerializer(serializers.ModelSerializer):
    place_info = serializers.SerializerMethodField()
    total_points = serializers.ReadOnlyField()

    class Meta:
        model = Mission
        fields = ['id', 'title', 'description', 'difficulty', 'base_points',
                  'distance_bonus', 'difficulty_bonus', 'total_points',
                  'place_info', 'is_active']

    def get_place_info(self, obj):
        return {
            'id': obj.place.id,
            'name': obj.place.name,
            'address': obj.place.address,
            'latitude': obj.place.latitude,
            'longitude': obj.place.longitude,
        }


class UserMissionSerializer(serializers.ModelSerializer):
    mission = MissionSerializer(read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = UserMission
        fields = ['id', 'mission', 'status', 'status_display',
                  'distance_from_user', 'started_at', 'completed_at',
                  'points_earned']
