# main.py
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from pydantic import BaseModel, Field
from typing import List
import sqlite3

DB_PATH = "fitness.db"

app = FastAPI(title="Exercise Recommendation API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # ← 이걸로 해결
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



# ---------- DB 연결 ----------
def get_connection():
    return sqlite3.connect(DB_PATH)


# ---------- 요청/응답 모델 ----------

class RecommendationRequest(BaseModel):
    ageGroup: str = Field(..., description="연령대 (예: '20대', '30대')")
    sex: str = Field(..., description="성별 코드 (예: 'M', 'F')")
    heightCm: float
    weightKg: float


class RecommendationLevel(BaseModel):
    level: str               # "상" / "중" / "하"
    prescriptions: List[str]


class RecommendationResponse(BaseModel):
    bmi: float
    difficulty: str          # "상" / "중" / "하"
    recommendations: List[RecommendationLevel]


# ---------- BMI 계산 & 난이도 분류 ----------

def calculate_bmi(height_cm: float, weight_kg: float) -> float:
    h = height_cm / 100.0
    return round(weight_kg / (h * h), 2)


def classify_difficulty(bmi: float) -> str:
    """
    예시 기준:
    - 하 : BMI < 18.5 또는 BMI >= 25
    - 중 : 23 <= BMI < 25
    - 상 : 18.5 <= BMI < 23
    """
    if bmi < 18.5 or bmi >= 25:
        return "하"
    elif 23 <= bmi < 25:
        return "중"
    else:
        return "상"


# ---------- 난이도별 운동 처방 조회 ----------

def fetch_prescriptions_for_level(
    age_group: str,
    sex: str,
    level: str,
    limit: int = 3,
) -> List[str]:
    """
    연령대 + 성별 + BMI 구간 기준으로 행을 고르고,
    행의 '마지막 컬럼'을 운동처방 텍스트로 사용한다.
    (컬럼 이름이 살짝 달라도 동작하도록)
    """
    conn = get_connection()
    cur = conn.cursor()

    # BMI = 체중(kg) / (키(m)^2)
    # 키/체중은 TEXT로 저장되었을 수 있으니 REAL로 캐스팅해서 계산
    if level == "하":
        sql = """
        SELECT *
        FROM FITNESS_MEASURE
        WHERE AGRDE_FLAG_NM = ?
          AND SEXDSTN_FLAG_CD = ?
          AND (
            (CAST(MESURE_IEM_002_VALUE AS REAL) /
             ((CAST(MESURE_IEM_001_VALUE AS REAL)/100.0) *
              (CAST(MESURE_IEM_001_VALUE AS REAL)/100.0)) < 18.5)
            OR
            (CAST(MESURE_IEM_002_VALUE AS REAL) /
             ((CAST(MESURE_IEM_001_VALUE AS REAL)/100.0) *
              (CAST(MESURE_IEM_001_VALUE AS REAL)/100.0)) >= 25.0)
          )
        LIMIT ?
        """
        cur.execute(sql, (age_group, sex, limit))
    else:
        if level == "상":
            bmi_min, bmi_max = 18.5, 23.0
        else:  # "중"
            bmi_min, bmi_max = 23.0, 25.0

        sql = """
        SELECT *
        FROM FITNESS_MEASURE
        WHERE AGRDE_FLAG_NM = ?
          AND SEXDSTN_FLAG_CD = ?
          AND (
            CAST(MESURE_IEM_002_VALUE AS REAL) /
            ((CAST(MESURE_IEM_001_VALUE AS REAL)/100.0) *
             (CAST(MESURE_IEM_001_VALUE AS REAL)/100.0))
          ) BETWEEN ? AND ?
        LIMIT ?
        """
        cur.execute(sql, (age_group, sex, bmi_min, bmi_max, limit))

    rows = cur.fetchall()
    conn.close()

    # 각 행의 마지막 컬럼을 '운동처방내용' 으로 사용
    pres = [r[-1] for r in rows if r and r[-1] is not None]

    # 혹시 해당 구간 데이터가 하나도 없을 때 대비 기본 문구
    if not pres:
        if level == "상":
            pres.append("유산소와 근력운동을 함께 진행해 전신 체력을 향상시키세요.")
        elif level == "중":
            pres.append("빠른 걷기와 가벼운 조깅을 주 3~4회 실천해 보세요.")
        else:
            pres.append("걷기, 실내 자전거 등 저충격 유산소 운동을 꾸준히 해주세요.")

    return pres



# ---------- 헬스 체크 ----------
@app.get("/health")
def health():
    return {"status": "ok"}


# ---------- 최종 추천 API ----------
@app.post("/recommendations", response_model=RecommendationResponse)
def get_recommendations(req: RecommendationRequest):
    # 1) 사용자 BMI 계산
    bmi = calculate_bmi(req.heightCm, req.weightKg)

    # 2) 난이도 분류
    diff = classify_difficulty(bmi)

    # 3) 난이도 상/중/하 각각에 대해 처방 가져오기
    levels = ["상", "중", "하"]
    result_levels: List[RecommendationLevel] = []

    for lv in levels:
        pres = fetch_prescriptions_for_level(
            age_group=req.ageGroup,
            sex=req.sex,
            level=lv,
            limit=3,
        )
        result_levels.append(
            RecommendationLevel(level=lv, prescriptions=pres)
        )

    # 4) BMI + 사용자 난이도 + 난이도별 처방 리스트 반환
    return RecommendationResponse(
        bmi=bmi,
        difficulty=diff,
        recommendations=result_levels,
    )
