from rest_framework import serializers
from .models import OutdoorEquipment

class OutdoorEquipmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = OutdoorEquipment
        fields = '__all__'