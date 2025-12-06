from django.db import models

class BikeRack(models.Model):
    자전거보관소명 = models.CharField(max_length=200)
    소재지도로명주소 = models.CharField(max_length=300, null=True, blank=True)
    소재지지번주소 = models.CharField(max_length=300, null=True, blank=True)
    보관대수 = models.CharField(max_length=50, null=True, blank=True)
    공기주입기비치여부 = models.CharField(max_length=50, null=True, blank=True)
    수리대설치여부 = models.CharField(max_length=50, null=True, blank=True)
    관리기관전화번호 = models.CharField(max_length=100, null=True, blank=True)
    관리기관명 = models.CharField(max_length=200, null=True, blank=True)
    데이터기준일자 = models.CharField(max_length=50, null=True, blank=True)

    # 좌표 필드
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)

    def save(self, *args, **kwargs):
        # 좌표가 없고 주소가 있으면 자동으로 geocoding
        if not self.latitude and not self.longitude:
            address = self.소재지도로명주소 or self.소재지지번주소
            if address:
                try:
                    from geocode.utils import geocode_address
                    lat, lon = geocode_address(address)
                    if lat and lon:
                        self.latitude = lat
                        self.longitude = lon
                except Exception as e:
                    print(f"Geocoding 실패 ({self.자전거보관소명}): {e}")
        super().save(*args, **kwargs)

    def __str__(self):
        return self.자전거보관소명