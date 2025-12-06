import csv
import tkinter as tk
from tkinter import filedialog
from django.core.management.base import BaseCommand
from corporations.models import Corporation


class Command(BaseCommand):
    help = "CSV 파일을 GUI로 선택하여 Corporation 데이터를 DB에 저장합니다."

    def handle(self, *args, **options):
        root = tk.Tk()
        root.withdraw()

        self.stdout.write(self.style.WARNING("📁 CSV 파일을 선택하세요."))

        file_path = filedialog.askopenfilename(
            title="법인 CSV 파일 선택",
            filetypes=[("CSV Files", "*.csv"), ("All Files", "*.*")]
        )

        if not file_path:
            self.stdout.write(self.style.ERROR("❌ 파일을 선택하지 않았습니다."))
            return

        self.stdout.write(self.style.SUCCESS(f"📄 선택한 파일: {file_path}"))

        # 🔥 CSV는 Windows에서 만든 경우 99% cp949 인코딩
        try:
            f = open(file_path, encoding='cp949', errors='ignore')
            reader = csv.DictReader(f)
            self.stdout.write(self.style.WARNING("📌 사용한 인코딩: cp949"))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"❌ 파일 열기 실패: {e}"))
            return

        count = 0

        for row in reader:
            실과명 = row.get("실과명")
            법인종류 = row.get("법인종류")
            허가번호 = row.get("허가번호")
            법인명칭 = row.get("법인명칭")
            대표자 = row.get("대표자")

            # 띄어쓰기 문제 있는 헤더 대응
            법인주소 = row.get("법  인  주  소") or row.get("법인주소")

            허가년도 = row.get("허가년도")
            임원 = row.get("임원")

            기능및목적 = row.get("기능 및 목적") or row.get("기능및목적")
            소관분야 = row.get("소관분야")

            비고 = row.get("비 고") or row.get("비고")

            # 법인명칭 필수
            if not 법인명칭 or 법인명칭.strip() == "":
                print("⚠ 법인명칭 없음 → 스킵:", row)
                continue

            Corporation.objects.create(
                실과명=실과명,
                법인종류=법인종류,
                허가번호=허가번호,
                법인명칭=법인명칭,
                대표자=대표자,
                법인주소=법인주소,
                허가년도=허가년도,
                임원=임원,
                기능및목적=기능및목적,
                소관분야=소관분야,
                비고=비고,
            )
            count += 1

        f.close()

        self.stdout.write(self.style.SUCCESS(f"🌟 총 {count}개 법인이 DB에 저장되었습니다!"))