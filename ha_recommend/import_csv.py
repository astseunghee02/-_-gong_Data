import sqlite3
import pandas as pd

DB_PATH = "fitness.db"
CSV_PATH = "FTNESS_MESURE.csv"  # 👉 새로 넣은 파일 이름

# 1) CSV 읽기 (인코딩은 상황에 따라 cp949 또는 utf-8-sig)
#    먼저 utf-8-sig로 시도해보고, 에러 나면 cp949로 바꿔서 다시 실행해봐.
df = pd.read_csv(CSV_PATH, encoding="utf-8-sig")
print("컬럼 목록:", df.columns)

# 2) 우리가 사용할 컬럼만 추출
#    (너가 처음에 올려준 스키마 기준)
#    AGRDE_FLAG_NM        연령대구분명
#    SEXDSTN_FLAG_CD      성별구분코드
#    MESURE_IEM_001_VALUE 신장(cm)
#    MESURE_IEM_002_VALUE 체중(kg)
#    MVM_PRSCRPTN_CN      운동처방내용
df_small = df[
    [
        "AGRDE_FLAG_NM",
        "SEXDSTN_FLAG_CD",
        "MESURE_IEM_001_VALUE",
        "MESURE_IEM_002_VALUE",
        "MVM_PRSCRPTN_CN",
    ]
].copy()

# 3) 핵심 값이 없는 행 제거
df_small = df_small.dropna(
    subset=[
        "AGRDE_FLAG_NM",
        "SEXDSTN_FLAG_CD",
        "MESURE_IEM_001_VALUE",
        "MESURE_IEM_002_VALUE",
        "MVM_PRSCRPTN_CN",
    ]
)

print("사용할 행 수:", len(df_small))

# 4) DB 연결
conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

# 기존 데이터 싹 지우고 새로 채우고 싶으면:
cur.execute("DELETE FROM FITNESS_MEASURE;")

# 5) INSERT
rows = df_small.itertuples(index=False, name=None)

cur.executemany(
    """
    INSERT INTO FITNESS_MEASURE
    (AGRDE_FLAG_NM, SEXDSTN_FLAG_CD,
     MESURE_IEM_001_VALUE, MESURE_IEM_002_VALUE, MVM_PRSCRPTN_CN)
    VALUES (?, ?, ?, ?, ?)
    """,
    rows,
)

conn.commit()
conn.close()

print("DB 삽입 완료! 총", len(df_small), "행 입력")
