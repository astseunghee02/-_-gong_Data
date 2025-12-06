import time
from django.core.management.base import BaseCommand
from corporations.models import Corporation
from bike_racks.models import BikeRack
from places.models import Place
from geocode.utils import geocode_address


class Command(BaseCommand):
    help = '주소를 경도/위도 좌표로 변환합니다'

    def add_arguments(self, parser):
        parser.add_argument(
            '--model',
            type=str,
            help='특정 모델만 처리 (corporations, bike_racks, places)',
        )
        parser.add_argument(
            '--delay',
            type=float,
            default=0.1,
            help='API 요청 사이의 지연 시간 (초)',
        )

    def handle(self, *args, **options):
        model_name = options.get('model')
        delay = options.get('delay')

        if not model_name or model_name == 'corporations':
            self.geocode_corporations(delay)

        if not model_name or model_name == 'bike_racks':
            self.geocode_bike_racks(delay)

        if not model_name or model_name == 'places':
            self.geocode_places(delay)

        self.stdout.write(self.style.SUCCESS('Geocoding 완료!'))

    def geocode_corporations(self, delay):
        self.stdout.write('Corporation 모델 geocoding 시작...')
        corporations = Corporation.objects.filter(
            latitude__isnull=True,
            longitude__isnull=True,
            법인주소__isnull=False
        ).exclude(법인주소='')

        total = corporations.count()
        self.stdout.write(f'총 {total}개의 Corporation을 처리합니다.')

        success_count = 0
        fail_count = 0

        for idx, corp in enumerate(corporations, 1):
            address = corp.법인주소
            if not address:
                continue

            try:
                lat, lon = geocode_address(address)
                if lat and lon:
                    corp.latitude = lat
                    corp.longitude = lon
                    corp.save()
                    success_count += 1
                    self.stdout.write(f'[{idx}/{total}] 성공: {corp.법인명칭} - {address}')
                else:
                    fail_count += 1
                    self.stdout.write(self.style.WARNING(f'[{idx}/{total}] 실패: {corp.법인명칭} - {address}'))
            except Exception as e:
                fail_count += 1
                self.stdout.write(self.style.ERROR(f'[{idx}/{total}] 오류: {corp.법인명칭} - {str(e)}'))

            time.sleep(delay)

        self.stdout.write(self.style.SUCCESS(f'Corporation: 성공 {success_count}, 실패 {fail_count}'))

    def geocode_bike_racks(self, delay):
        self.stdout.write('BikeRack 모델 geocoding 시작...')
        bike_racks = BikeRack.objects.filter(
            latitude__isnull=True,
            longitude__isnull=True
        )

        total = bike_racks.count()
        self.stdout.write(f'총 {total}개의 BikeRack을 처리합니다.')

        success_count = 0
        fail_count = 0

        for idx, rack in enumerate(bike_racks, 1):
            # 도로명 주소 우선, 없으면 지번 주소 사용
            address = rack.소재지도로명주소 or rack.소재지지번주소
            if not address:
                continue

            try:
                lat, lon = geocode_address(address)
                if lat and lon:
                    rack.latitude = lat
                    rack.longitude = lon
                    rack.save()
                    success_count += 1
                    self.stdout.write(f'[{idx}/{total}] 성공: {rack.자전거보관소명} - {address}')
                else:
                    fail_count += 1
                    self.stdout.write(self.style.WARNING(f'[{idx}/{total}] 실패: {rack.자전거보관소명} - {address}'))
            except Exception as e:
                fail_count += 1
                self.stdout.write(self.style.ERROR(f'[{idx}/{total}] 오류: {rack.자전거보관소명} - {str(e)}'))

            time.sleep(delay)

        self.stdout.write(self.style.SUCCESS(f'BikeRack: 성공 {success_count}, 실패 {fail_count}'))

    def geocode_places(self, delay):
        self.stdout.write('Place 모델 geocoding 시작...')
        places = Place.objects.filter(
            latitude__isnull=True,
            longitude__isnull=True,
            address__isnull=False
        ).exclude(address='')

        total = places.count()
        self.stdout.write(f'총 {total}개의 Place를 처리합니다.')

        success_count = 0
        fail_count = 0

        for idx, place in enumerate(places, 1):
            address = place.address
            if not address:
                continue

            try:
                lat, lon = geocode_address(address)
                if lat and lon:
                    place.latitude = lat
                    place.longitude = lon
                    place.save()
                    success_count += 1
                    self.stdout.write(f'[{idx}/{total}] 성공: {place.name} - {address}')
                else:
                    fail_count += 1
                    self.stdout.write(self.style.WARNING(f'[{idx}/{total}] 실패: {place.name} - {address}'))
            except Exception as e:
                fail_count += 1
                self.stdout.write(self.style.ERROR(f'[{idx}/{total}] 오류: {place.name} - {str(e)}'))

            time.sleep(delay)

        self.stdout.write(self.style.SUCCESS(f'Place: 성공 {success_count}, 실패 {fail_count}'))
