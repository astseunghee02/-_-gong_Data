import pandas as pd

CSV_PATH = "체력측정_운동처방.csv"   # ← 네 파일명으로 바꿔줘!

df = pd.read_csv(CSV_PATH, encoding="utf-8-sig")  # 또는 cp949
print(df.columns)
