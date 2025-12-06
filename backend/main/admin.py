from django.contrib import admin
from .models import OutdoorEquipment, SportsFacility


@admin.register(OutdoorEquipment)
class OutdoorEquipmentAdmin(admin.ModelAdmin):
    list_display = ("name", "address")  # 필요 시 수정


@admin.register(SportsFacility)
class SportsFacilityAdmin(admin.ModelAdmin):
    list_display = ("location", "place", "reservation", "address")
    search_fields = ("location", "place", "address")