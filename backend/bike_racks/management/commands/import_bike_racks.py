import csv
import tkinter as tk
from tkinter import filedialog
from django.core.management.base import BaseCommand
from bike_racks.models import BikeRack


class Command(BaseCommand):
    help = "CSV 파일을 선택해서 자전거 보관소 데이터를 DB에 저장합니다."

    def handle(self, *args, **options):
        # GUI 창 생성
        root = tk.Tk()
        root.withdraw()  # 창 숨기기

        self.stdout.write(self.style.WARNING("📁 CSV 파일을 선택하세요."))

        file_path = filedialog.askopenfilename(
            title="자전거보관소 CSV 파일 선택",
            filetypes=[("CSV Files", "*.csv"), ("All Files", "*.*")]
        )

        if not file_path:
            self.stdout.write(self.style.ERROR("❌ 파일 선택 안 함"))
            return

        self.stdout.write(self.style.SUCCESS(f"📄 선택한 파일: {file_path}"))

        # 🔥 Windows CSV 기본 인코딩: cp949
        try:
            f = open(file_path, encoding='cp949', errors='ignore')
            reader = csv.DictReader(f)
            self.stdout.write(self.style.WARNING("📌 사용된 인코딩: cp949"))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"❌ 파일 열기 실패: {e}"))
            return

        count = 0

        for row in reader:
            자전거보관소명 = row.get("자전거보관소명")
            소재지도로명주소 = row.get("소재지도로명주소")
            소재지지번주소 = row.get("소재지지번주소")
            보관대수 = row.get("보관대수")
            공기주입기비치여부 = row.get("공기주입기비치여부")
            수리대설치여부 = row.get("수리대설치여부")
            관리기관전화번호 = row.get("관리기관전화번호")
            관리기관명 = row.get("관리기관명")
            데이터기준일자 = row.get("데이터기준일자")

            # 필수값이 없으면 스킵
            if not 자전거보관소명:
                print("⚠ 자전거보관소명 없음 → 스킵:", row)
                continue

            BikeRack.objects.create(
                자전거보관소명=자전거보관소명,
                소재지도로명주소=소재지도로명주소,
                소재지지번주소=소재지지번주소,
                보관대수=보관대수,
                공기주입기비치여부=공기주입기비치여부,
                수리대설치여부=수리대설치여부,
                관리기관전화번호=관리기관전화번호,
                관리기관명=관리기관명,
                데이터기준일자=데이터기준일자,
            )

            count += 1

        f.close()

        self.stdout.write(self.style.SUCCESS(f"🌟 총 {count}개의 자전거보관소 데이터 저장 완료!"))