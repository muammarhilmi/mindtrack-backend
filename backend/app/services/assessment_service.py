from datetime import datetime
from app.db.mongodb import db
from bson import ObjectId


# ==========================
# KATEGORI SKOR FINAL (gabungan mental + lifestyle)
# ==========================
def get_level(score: int) -> str:
    if score >= 80:
        return "Sangat Baik"
    elif score >= 60:
        return "Baik"
    elif score >= 40:
        return "Sedang"
    elif score >= 20:
        return "Kurang"
    else:
        return "Buruk"


# ==========================
# KATEGORI RESMI PER INSTRUMEN
# ==========================
def get_phq_level(score: int) -> str:
    # PHQ-9, skor max 27
    if score >= 20:
        return "Berat"
    elif score >= 15:
        return "Sedang Berat"
    elif score >= 10:
        return "Sedang"
    elif score >= 5:
        return "Ringan"
    else:
        return "Minimal"


def get_gad_level(score: int) -> str:
    # GAD-7, skor max 21
    if score >= 15:
        return "Berat"
    elif score >= 10:
        return "Sedang"
    elif score >= 5:
        return "Ringan"
    else:
        return "Minimal"


def get_stress_level(score: int) -> str:
    # DASS-21 Stress, skor sudah dikali 2 (max 42) agar sesuai norma DASS-42
    if score >= 34:
        return "Sangat Berat"
    elif score >= 26:
        return "Berat"
    elif score >= 19:
        return "Sedang"
    elif score >= 15:
        return "Ringan"
    else:
        return "Normal"


def create_assessment(user_id: str, data):

    # ==========================
    # SKOR PHQ / GAD / STRESS
    # ==========================
    phq_score = sum(data.phq_answers)           # max 27
    gad_score = sum(data.gad_answers)            # max 21
    stress_score = sum(data.stress_answers) * 2  # max 42 (konvensi resmi DASS-21)

    phq_level = get_phq_level(phq_score)
    gad_level = get_gad_level(gad_score)
    stress_level = get_stress_level(stress_score)

    # Normalisasi tiap skor ke persentase (0-100) sebelum dirata-rata,
    # karena skala maksimum tiap instrumen berbeda (27 / 21 / 42)
    mental_percentage = round(100 - (
        (
            (phq_score / 27) +
            (gad_score / 21) +
            (stress_score / 42)
        ) / 3 * 100
    ))

    # ==========================
    # AKTIVITAS HARIAN
    # ==========================
    sleep_score = min((data.sleep_hours / 8) * 100, 100)
    quality_score = (data.sleep_quality / 4) * 100
    activity_score = (data.physical_activity / 4) * 100
    social_score = (data.social_interaction / 4) * 100
    productivity_score = (data.productivity / 4) * 100

    lifestyle_score = round((
        sleep_score +
        quality_score +
        activity_score +
        social_score +
        productivity_score
    ) / 5)

    # ==========================
    # SKOR AKHIR
    # ==========================
    final_score = round(
        (mental_percentage * 0.7) +
        (lifestyle_score * 0.3)
    )

    level = get_level(final_score)

    assessment = {
        "user_id": user_id,

        "phq_answers": data.phq_answers,
        "gad_answers": data.gad_answers,
        "stress_answers": data.stress_answers,

        "sleep_hours": data.sleep_hours,
        "sleep_quality": data.sleep_quality,
        "physical_activity": data.physical_activity,
        "social_interaction": data.social_interaction,
        "productivity": data.productivity,

        "phq_score": phq_score,
        "gad_score": gad_score,
        "stress_score": stress_score,

        "phq_level": phq_level,
        "gad_level": gad_level,
        "stress_level": stress_level,

        "mental_percentage": mental_percentage,
        "lifestyle_score": lifestyle_score,
        "final_score": final_score,
        "level": level,

        "created_at": datetime.utcnow(),
    }

    db.assessments.insert_one(assessment)

    return {
        "phq_score": phq_score,
        "gad_score": gad_score,
        "stress_score": stress_score,

        "phq_level": phq_level,
        "gad_level": gad_level,
        "stress_level": stress_level,

        "mental_percentage": mental_percentage,
        "lifestyle_score": lifestyle_score,
        "final_score": final_score,
        "level": level,

        "sleep_hours": data.sleep_hours,
        "social_interaction": data.social_interaction,
        "productivity": data.productivity,
    }


def get_assessment_history(user_id: str):

    assessments = list(
        db.assessments.find({"user_id": user_id}).sort("created_at", -1)
    )

    result = []

    for item in assessments:
        result.append({
            "id": str(item["_id"]),
            "created_at": item["created_at"],

            "phq_score": item["phq_score"],
            "gad_score": item["gad_score"],
            "stress_score": item["stress_score"],

            "phq_level": item.get("phq_level", "-"),
            "gad_level": item.get("gad_level", "-"),
            "stress_level": item.get("stress_level", "-"),

            "mental_percentage": item.get("mental_percentage", 0),
            "lifestyle_score": item.get("lifestyle_score", 0),
            "final_score": item.get("final_score", 0),
            "level": item.get("level", "-"),

            "sleep_hours": item.get("sleep_hours", 0),
            "social_interaction": item.get("social_interaction", 0),
            "productivity": item.get("productivity", 0),
        })

    return result


def get_assessment_detail(assessment_id: str):
    item = db.assessments.find_one({"_id": ObjectId(assessment_id)})

    if not item:
        return None

    return {
        "id": str(item["_id"]),
        "user_id": item["user_id"],
        "created_at": item["created_at"],

        "phq_score": item["phq_score"],
        "gad_score": item["gad_score"],
        "stress_score": item["stress_score"],

        "phq_level": item.get("phq_level", "-"),
        "gad_level": item.get("gad_level", "-"),
        "stress_level": item.get("stress_level", "-"),

        "mental_percentage": item["mental_percentage"],
        "lifestyle_score": item["lifestyle_score"],
        "final_score": item["final_score"],
        "level": item["level"],

        "sleep_hours": item["sleep_hours"],
        "social_interaction": item["social_interaction"],
        "productivity": item["productivity"],
    }