from django.db import models

class Corporation(models.Model):
    실과명 = models.CharField(max_length=100, blank=True, null=True)
    법인종류 = models.CharField(max_length=100, blank=True, null=True)
    허가번호 = models.CharField(max_length=100, blank=True, null=True)
    법인명칭 = models.CharField(max_length=200, blank=True, null=True)
    대표자 = models.CharField(max_length=100, blank=True, null=True)
    법인주소 = models.CharField(max_length=300, blank=True, null=True)
    허가년도 = models.CharField(max_length=20, blank=True, null=True)
    임원 = models.TextField(blank=True, null=True)
    기능및목적 = models.TextField(blank=True, null=True)
    소관분야 = models.CharField(max_length=200, blank=True, null=True)
    비고 = models.CharField(max_length=200, blank=True, null=True)

    # 좌표 필드
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)

    def save(self, *args, **kwargs):
        # 좌표가 없고 주소가 있으면 자동으로 geocoding
        if self.법인주소 and not self.latitude and not self.longitude:
            try:
                from geocode.utils import geocode_address
                lat, lon = geocode_address(self.법인주소)
                if lat and lon:
                    self.latitude = lat
                    self.longitude = lon
            except Exception as e:
                print(f"Geocoding 실패 ({self.법인명칭}): {e}")
        super().save(*args, **kwargs)

    def __str__(self):
        return self.법인명칭 or "Unknown Corporation"