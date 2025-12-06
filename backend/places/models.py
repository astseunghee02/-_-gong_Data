from django.db import models
import re


class Place(models.Model):
    name = models.CharField(max_length=100)
    address = models.CharField(max_length=255)
    facilities_raw = models.TextField()
    contact = models.CharField(max_length=100)

    # 좌표 필드
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)

    @property
    def facilities(self):
        # 파일 원본 문자열을 리스트로 변환
        if not self.facilities_raw:
            return []
        parts = re.split(r'[+,]', self.facilities_raw)
        return [p.strip() for p in parts if p.strip()]

    def save(self, *args, **kwargs):
        # 좌표가 없고 주소가 있으면 자동으로 geocoding
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