from django.db import models

class OutdoorEquipment(models.Model):
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)

    equipment_info = models.JSONField(default=dict)   # 운동기구 1~10 저장하는 필드

    def save(self, *args, **kwargs):
        if self.address and not self.latitude and not self.longitude:
            try:
                from geocode.utils import geocode_address
                lat, lon = geocode_address(self.address)
                if lat and lon:
                    self.latitude = lat
                    self.longitude = lon
            except Exception as e:
                print(f"Geocoding 실패 ({self.name}): {e}")
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

class SportsFacility(models.Model):
    location = models.CharField(max_length=200)      # 위치
    place = models.CharField(max_length=200)         # 장소
    reservation = models.CharField(max_length=200, blank=True)  # 예약정보
    address = models.CharField(max_length=300, blank=True)      # 주소
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)

    def save(self, *args, **kwargs):
        if self.address and not self.latitude and not self.longitude:
            try:
                from geocode.utils import geocode_address
                lat, lon = geocode_address(self.address)
                if lat and lon:
                    self.latitude = lat
                    self.longitude = lon
            except Exception as e:
                print(f"Geocoding 실패 ({self.place}): {e}")
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.place} ({self.location})"
