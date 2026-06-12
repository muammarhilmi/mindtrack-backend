from datetime import datetime

from app.db.mongodb import db


def get_phq_level(score: int):
    if score <= 4:
        return "Minimal"
    elif score <= 9:
        return "Ringan"
    elif score <= 14:
        return "Sedang"
    return "Berat"


def get_gad_level(score: int):
    if score <= 4:
        return "Minimal"
    elif score <= 9:
        return "Ringan"
    elif score <= 14:
        return "Sedang"
    return "Berat"


def get_stress_level(score: int):
    if score <= 4:
        return "Normal"
    elif score <= 9:
        return "Ringan"
    elif score <= 14:
        return "Sedang"
    return "Berat"


def create_assessment(user_id: str, data):
    phq_score = sum(data.phq_answers)
    gad_score = sum(data.gad_answers)
    stress_score = sum(data.stress_answers)

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

        "created_at": datetime.utcnow(),
    }

    db.assessments.insert_one(assessment)

    return {
        "phq_score": phq_score,
        "gad_score": gad_score,
        "stress_score": stress_score,

        "phq_level": get_phq_level(phq_score),
        "gad_level": get_gad_level(gad_score),
        "stress_level": get_stress_level(stress_score),
    }