# insert_sample_data.py
import sqlite3

# fitness.db에 연결 (같은 폴더에 있어야 함)
conn = sqlite3.connect("fitness.db")
cur = conn.cursor()

# 샘플 데이터 몇 개 (연령대, 성별, 키, 체중, 운동처방내용)
rows = [
    # 20대 여성 - BMI 정상 (난이도 상에 가까운 데이터)
    ("20대", "F", "160", "52",
     "주 3~4회, 인터벌 러닝과 코어 운동을 병행해 전신 체력을 향상시키세요."),
    ("20대", "F", "162", "54",
     "스쿼트, 런지 등 근력운동과 가벼운 조깅을 함께 진행해 하체 근력을 키워보세요."),

    # 20대 여성 - BMI 약간 높은 편 (난이도 중/하 구간 데이터)
    ("20대", "F", "158", "62",
     "빠른 걷기와 실내 자전거를 주 4회 진행해 체지방을 천천히 줄이세요."),
    ("20대", "F", "160", "70",
     "무릎 부담을 줄이기 위해 걷기, 수영 등 저충격 유산소 위주로 운동하세요."),

    # 30대 남성 - 여러 BMI 구간 섞어서
    ("30대", "M", "175", "70",
     "전신 근력운동과 인터벌 러닝을 주 3회 진행해 체력을 유지하세요."),
    ("30대", "M", "175", "88",
     "걷기, 실내 자전거 위주의 저강도 유산소를 주 5회 진행해 체중을 관리하세요.")
]

cur.executemany("""
INSERT INTO FITNESS_MEASURE
(AGRDE_FLAG_NM, SEXDSTN_FLAG_CD, MESURE_IEM_001_VALUE, MESURE_IEM_002_VALUE, MVM_PRSCPTN_CN)
VALUES (?, ?, ?, ?, ?);
""", rows)

conn.commit()
conn.close()

print("샘플 데이터 삽입 완료!")
