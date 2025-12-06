from django.db import models

class OutdoorEquipment(models.Model):
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)

    equipment_info = models.JSONField(default=dict)   # 운동기구 1~10 저장하는 필드

    def __str__(self):
        return self.name

class SportsFacility(models.Model):
    location = models.CharField(max_length=200)      # 위치
    place = models.CharField(max_length=200)         # 장소
    reservation = models.CharField(max_length=200, blank=True)  # 예약정보
    address = models.CharField(max_length=300, blank=True)      # 주소

    def __str__(self):
        return f"{self.place} ({self.location})"