from fastapi import APIRouter

from app.db.mongodb import db

router = APIRouter(tags=["Trends"])


@router.get("/weekly-trend")
def weekly_trend():
    collection = db["weekly_trend"]
    data = list(collection.find({}, {"_id": 0}))

    if len(data) < 2:
        return {"message": "Data trend tidak cukup"}

    latest = data[-1]
    previous = data[-2]

    return {
        "burnout": {
            "score": latest["burnout"],
            "change": latest["burnout"] - previous["burnout"],
        },
        "anxiety": {
            "score": latest["anxiety"],
            "change": latest["anxiety"] - previous["anxiety"],
        },
        "depression": {
            "score": latest["depression"],
            "change": latest["depression"] - previous["depression"],
        },
    }
