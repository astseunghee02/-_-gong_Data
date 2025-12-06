from django.core.management.base import BaseCommand
from main.models import OutdoorEquipment
from main.utils import fetch_equipment_data


class Command(BaseCommand):
    help = "충청남도 천안시 실외운동기구 정보를 API에서 불러와 DB에 저장"

    def handle(self, *args, **kwargs):
        data = fetch_equipment_data()
        items = data.get("data", [])

        if not items:
            self.stdout.write(self.style.WARNING("API 결과에 data가 비어있음."))
            return

        saved_count = 0

        for item in items:
            name = item.get("시설명")

            # 시설명 없거나 더미값이면 skip
            if not name or name == "string":
                continue

            # 운동기구 1~10 유동적 수집
            equip_data = {}
            for i in range(1, 11):
                eq_name_key = f"운동기구{i}"
                eq_count_key = f"운동기구{i} 개수"

                if item.get(eq_name_key):  # 값이 있을 경우만 저장
                    equip_data[eq_name_key] = item.get(eq_name_key)
                    equip_data[eq_count_key] = item.get(eq_count_key, 0)

            OutdoorEquipment.objects.update_or_create(
                name=name,
                defaults={
                    "address": item.get("소재지") or "",
                    "equipment_info": equip_data,
                },
            )

            saved_count += 1

        self.stdout.write(self.style.SUCCESS(f"총 {saved_count}개의 운동기구 정보 저장 완료"))