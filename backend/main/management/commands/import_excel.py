import csv
from django.core.management.base import BaseCommand
from main.models import SportsFacility


class Command(BaseCommand):
    help = "CSV 데이터를 SportsFacility DB에 저장합니다. (기존 데이터 모두 삭제 후 재생성)"

    def add_arguments(self, parser):
        parser.add_argument("csv_path", type=str, help="CSV 파일 경로")

    def handle(self, *args, **options):
        csv_path = options["csv_path"]

        # 1) 기존 데이터 전체 삭제
        SportsFacility.objects.all().delete()

        try:
            # 기본은 UTF-8-SIG로 시도
            try:
                f = open(csv_path, newline='', encoding="utf-8-sig")
            except UnicodeDecodeError:
                f = open(csv_path, newline='', encoding="cp949")

            reader = csv.DictReader(f)
            count = 0

            for row in reader:
                location = (row.get("위치") or "").strip()
                place = (row.get("장소") or "").strip()
                reservation = (row.get("예약정보") or "").strip()
                address = (row.get("주소") or "").strip()

                # CSV 한 줄 = DB 한 레코드 그대로 생성
                SportsFacility.objects.create(
                    location=location,
                    place=place,
                    reservation=reservation,
                    address=address,
                )
                count += 1

            f.close()
            self.stdout.write(self.style.SUCCESS(f"총 {count}개 시설 저장 완료!"))

        except Exception as e:
            self.stdout.write(self.style.ERROR(f"CSV 읽기 실패: {e}"))