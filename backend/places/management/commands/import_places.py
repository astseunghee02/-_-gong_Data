import csv
import re
from django.core.management.base import BaseCommand
from places.models import Place

# Tkinter를 이용한 파일 선택 GUI
import tkinter as tk
from tkinter import filedialog


class Command(BaseCommand):
    help = "GUI 창을 통해 CSV 파일을 선택하여 장소 데이터를 DB에 저장합니다."

    def handle(self, *args, **options):
        # GUI 창 준비
        root = tk.Tk()
        root.withdraw()  # Tkinter 메인 윈도우 숨기기

        self.stdout.write(self.style.WARNING("📁 CSV 파일을 선택하세요."))

        # 파일 선택창 열기
        file_path = filedialog.askopenfilename(
            title="CSV 파일 선택",
            filetypes=[("CSV Files", "*.csv"), ("All Files", "*.*")]
        )

        if not file_path:
            self.stdout.write(self.style.ERROR("❌ 파일을 선택하지 않았습니다. 작업을 취소합니다."))
            return

        self.stdout.write(self.style.SUCCESS(f"📄 선택한 파일: {file_path}"))

        # CSV 읽기
        count = 0
        with open(file_path, encoding='utf-8-sig') as f:
            reader = csv.DictReader(f)
            for row in reader:
                
                name = row.get("명칭")
                address = row.get("주소")
                facilities_raw = row.get("주요시설", "")
                contact = row.get("문의처")

                Place.objects.create(
                    name=name,
                    address=address,
                    facilities_raw=facilities_raw,
                    contact=contact
                )
                count += 1

        self.stdout.write(self.style.SUCCESS(f"🌟 총 {count}개 데이터가 DB에 저장되었습니다!"))