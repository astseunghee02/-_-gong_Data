import time
from django.core.management.base import BaseCommand
from corporations.models import Corporation
from bike_racks.models import BikeRack
from places.models import Place
from main.models import OutdoorEquipment, SportsFacility


class Command(BaseCommand):
    help = '기존 데이터의 주소를 경도/위도 좌표로 변환합니다 (save() 메서드 사용)'

    def add_arguments(self, parser):
        parser.add_argument(
            '--model',
            type=str,
            help='특정 모델만 처리 (corporations, bike_racks, places, outdoor, sports)',
        )
        parser.add_argument(
            '--delay',
            type=float,
            default=0.1,
            help='API 요청 사이의 지연 시간 (초)',
        )
        parser.add_argument(
            '--limit',
            type=int,
            help='처리할 최대 레코드 수 (테스트용)',
        )

    def handle(self, *args, **options):
        model_name = options.get('model')
        delay = options.get('delay')
        limit = options.get('limit')

        if not model_name or model_name == 'corporations':
            self.update_corporations(delay, limit)

        if not model_name or model_name == 'bike_racks':
            self.update_bike_racks(delay, limit)

        if not model_name or model_name == 'places':
            self.update_places(delay, limit)

        if not model_name or model_name in ('outdoor', 'outdoorequipment', 'outdoor_equipment'):
            self.update_outdoor_equipment(delay, limit)

        if not model_name or model_name in ('sports', 'sportsfacility', 'sports_facility'):
            self.update_sports_facility(delay, limit)

        self.stdout.write(self.style.SUCCESS('✅ 좌표 업데이트 완료!'))

    def update_corporations(self, delay, limit=None):
        self.stdout.write('📍 Corporation 데이터 업데이트 시작...')

        corporations = Corporation.objects.filter(
            latitude__isnull=True,
            longitude__isnull=True,
            법인주소__isnull=False
        ).exclude(법인주소='')

        if limit:
            corporations = corporations[:limit]

        total = corporations.count()
        self.stdout.write(f'총 {total}개의 Corporation을 처리합니다.')

        success_count = 0
        fail_count = 0

        for idx, corp in enumerate(corporations, 1):
            try:
                # save()를 호출하면 자동으로 geocoding 실행
                corp.save()

                if corp.latitude and corp.longitude:
                    success_count += 1
                    self.stdout.write(f'[{idx}/{total}] ✅ {corp.법인명칭} - ({corp.latitude}, {corp.longitude})')
                else:
                    fail_count += 1
                    self.stdout.write(self.style.WARNING(f'[{idx}/{total}] ⚠️  {corp.법인명칭} - 좌표 변환 실패'))
            except Exception as e:
                fail_count += 1
                self.stdout.write(self.style.ERROR(f'[{idx}/{total}] ❌ {corp.법인명칭} - 오류: {str(e)}'))

            time.sleep(delay)

        self.stdout.write(self.style.SUCCESS(f'Corporation: 성공 {success_count}, 실패 {fail_count}'))

    def update_bike_racks(self, delay, limit=None):
        self.stdout.write('📍 BikeRack 데이터 업데이트 시작...')

        bike_racks = BikeRack.objects.filter(
            latitude__isnull=True,
            longitude__isnull=True
        )

        if limit:
            bike_racks = bike_racks[:limit]

        total = bike_racks.count()
        self.stdout.write(f'총 {total}개의 BikeRack을 처리합니다.')

        success_count = 0
        fail_count = 0

        for idx, rack in enumerate(bike_racks, 1):
            address = rack.소재지도로명주소 or rack.소재지지번주소
            if not address:
                fail_count += 1
                continue

            try:
                # save()를 호출하면 자동으로 geocoding 실행
                rack.save()

                if rack.latitude and rack.longitude:
                    success_count += 1
                    self.stdout.write(f'[{idx}/{total}] ✅ {rack.자전거보관소명} - ({rack.latitude}, {rack.longitude})')
                else:
                    fail_count += 1
                    self.stdout.write(self.style.WARNING(f'[{idx}/{total}] ⚠️  {rack.자전거보관소명} - 좌표 변환 실패'))
            except Exception as e:
                fail_count += 1
                self.stdout.write(self.style.ERROR(f'[{idx}/{total}] ❌ {rack.자전거보관소명} - 오류: {str(e)}'))

            time.sleep(delay)

        self.stdout.write(self.style.SUCCESS(f'BikeRack: 성공 {success_count}, 실패 {fail_count}'))

    def update_places(self, delay, limit=None):
        self.stdout.write('📍 Place 데이터 업데이트 시작...')

        places = Place.objects.filter(
            latitude__isnull=True,
            longitude__isnull=True,
            address__isnull=False
        ).exclude(address='')

        if limit:
            places = places[:limit]

        total = places.count()
        self.stdout.write(f'총 {total}개의 Place를 처리합니다.')

        success_count = 0
        fail_count = 0

        for idx, place in enumerate(places, 1):
            try:
                # save()를 호출하면 자동으로 geocoding 실행
                place.save()

                if place.latitude and place.longitude:
                    success_count += 1
                    self.stdout.write(f'[{idx}/{total}] ✅ {place.name} - ({place.latitude}, {place.longitude})')
                else:
                    fail_count += 1
                    self.stdout.write(self.style.WARNING(f'[{idx}/{total}] ⚠️  {place.name} - 좌표 변환 실패'))
            except Exception as e:
                fail_count += 1
                self.stdout.write(self.style.ERROR(f'[{idx}/{total}] ❌ {place.name} - 오류: {str(e)}'))

            time.sleep(delay)

        self.stdout.write(self.style.SUCCESS(f'Place: 성공 {success_count}, 실패 {fail_count}'))

    def update_outdoor_equipment(self, delay, limit=None):
        self.stdout.write('📍 OutdoorEquipment 데이터 업데이트 시작...')

        equipments = OutdoorEquipment.objects.filter(
            latitude__isnull=True,
            longitude__isnull=True,
            address__isnull=False
        ).exclude(address='')

        if limit:
            equipments = equipments[:limit]

        total = equipments.count()
        self.stdout.write(f'총 {total}개의 OutdoorEquipment을 처리합니다.')

        success_count = 0
        fail_count = 0

        for idx, equipment in enumerate(equipments, 1):
            try:
                equipment.save()  # save()가 주소 기반 geocode 실행

                if equipment.latitude and equipment.longitude:
                    success_count += 1
                    self.stdout.write(f'[{idx}/{total}] ✅ {equipment.name} - ({equipment.latitude}, {equipment.longitude})')
                else:
                    fail_count += 1
                    self.stdout.write(self.style.WARNING(f'[{idx}/{total}] ⚠️  {equipment.name} - 좌표 변환 실패'))
            except Exception as e:
                fail_count += 1
                self.stdout.write(self.style.ERROR(f'[{idx}/{total}] ❌ {equipment.name} - 오류: {str(e)}'))

            time.sleep(delay)

        self.stdout.write(self.style.SUCCESS(f'OutdoorEquipment: 성공 {success_count}, 실패 {fail_count}'))

    def update_sports_facility(self, delay, limit=None):
        self.stdout.write('📍 SportsFacility 데이터 업데이트 시작...')

        facilities = SportsFacility.objects.filter(
            latitude__isnull=True,
            longitude__isnull=True,
            address__isnull=False
        ).exclude(address='')

        if limit:
            facilities = facilities[:limit]

        total = facilities.count()
        self.stdout.write(f'총 {total}개의 SportsFacility를 처리합니다.')

        success_count = 0
        fail_count = 0

        for idx, facility in enumerate(facilities, 1):
            try:
                facility.save()  # save()가 주소 기반 geocode 실행

                if facility.latitude and facility.longitude:
                    success_count += 1
                    self.stdout.write(f'[{idx}/{total}] ✅ {facility.place} - ({facility.latitude}, {facility.longitude})')
                else:
                    fail_count += 1
                    self.stdout.write(self.style.WARNING(f'[{idx}/{total}] ⚠️  {facility.place} - 좌표 변환 실패'))
            except Exception as e:
                fail_count += 1
                self.stdout.write(self.style.ERROR(f'[{idx}/{total}] ❌ {facility.place} - 오류: {str(e)}'))

            time.sleep(delay)

        self.stdout.write(self.style.SUCCESS(f'SportsFacility: 성공 {success_count}, 실패 {fail_count}'))
