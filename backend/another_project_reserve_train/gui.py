import tkinter as tk
from tkinter import messagebox
from tkinter.ttk import Combobox
import com
def check_credentials():
    # 입력값 가져오기
    phone_front = entry_phone_front.get()
    phone_back = entry_phone_back.get()
    password = entry_password.get()
    selected_month = month_combobox.get()
    selected_day = day_combobox.get()
    selected_hour = hour_combobox.get()
    sk.main(phone_front,phone_back,password,selected_month,selected_day,selected_hour)

# 메인 창 생성
root = tk.Tk()
root.title("로그인 창")
root.geometry("500x300")
root.resizable(False, False)

# 전화번호 라벨
label_phone = tk.Label(root, text="전화번호:", font=("Arial", 12))
label_phone.grid(row=0, column=0, padx=10, pady=10, sticky="e")

# 전화번호 앞자리 입력 필드
entry_phone_front = tk.Entry(root, width=10, font=("Arial", 12))
entry_phone_front.grid(row=0, column=1, padx=5, pady=10, sticky="w")

# 전화번호 "-" 표시
label_dash = tk.Label(root, text="-", font=("Arial", 12))
label_dash.grid(row=0, column=2, padx=2, pady=10)

# 전화번호 뒷자리 입력 필드
entry_phone_back = tk.Entry(root, width=10, font=("Arial", 12))
entry_phone_back.grid(row=0, column=3, padx=5, pady=10, sticky="w")

# 비밀번호 라벨
label_password = tk.Label(root, text="비밀번호:", font=("Arial", 12))
label_password.grid(row=1, column=0, padx=10, pady=10, sticky="e")

# 비밀번호 입력 필드
entry_password = tk.Entry(root, width=25, font=("Arial", 12), show="*")
entry_password.grid(row=1, column=1, columnspan=3, padx=10, pady=10, sticky="w")

# 날짜 라벨
label_date = tk.Label(root, text="날짜:", font=("Arial", 12))
label_date.grid(row=2, column=0, padx=10, pady=10, sticky="e")

# 월 드롭다운 (Combobox)
month_combobox = Combobox(root, values=[f"{i}" for i in range(1, 13)], font=("Arial", 12), width=5)
month_combobox.grid(row=2, column=1, padx=5, pady=10, sticky="w")
month_combobox.set("월")  # 기본값 설정

# 일 드롭다운 (Combobox)
day_combobox = Combobox(root, values=[f"{i}" for i in range(1, 32)], font=("Arial", 12), width=5)
day_combobox.grid(row=2, column=2, padx=5, pady=10, sticky="w")
day_combobox.set("일")  # 기본값 설정

# 시간 라벨
label_time = tk.Label(root, text="시간:", font=("Arial", 12))
label_time.grid(row=3, column=0, padx=10, pady=10, sticky="e")

# 시간 드롭다운 (Combobox)
hour_combobox = Combobox(root, values=[f"{i}" for i in range(0, 24)], font=("Arial", 12), width=5)
hour_combobox.grid(row=3, column=1, padx=5, pady=10, sticky="w")
hour_combobox.set("시간")  # 기본값 설정

# 확인 버튼
button_check = tk.Button(root, text="확인", command=check_credentials, font=("Arial", 12), bg="blue", fg="black")
button_check.grid(row=4, column=0, columnspan=4, pady=20)
# 메인 루프 실행
root.mainloop()