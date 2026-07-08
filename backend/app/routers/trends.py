from fastapi import APIRouter
from app.db.mongodb import db

router = APIRouter(tags=["Trends"])

@router.get("/weekly-trend")
def weekly_trend():
    collection = db["weekly_trend"]
    # Ambil semua data trend, urutkan dari yang lama ke yang terbaru
    data = list(collection.find({}, {"_id": 0}))

    if len(data) < 2:
        return {"message": "Data trend tidak cukup"}

    latest = data[-1]
    previous = data[-2]

    # Ambil semua list historis nilai dari database untuk grafik
    burnout_history = [doc["burnout"] for doc in data]
    anxiety_history = [doc["anxiety"] for doc in data]
    depression_history = [doc["depression"] for doc in data]

    return {
        "burnout": {
            "score": latest["burnout"],
            "change": latest["burnout"] - previous["burnout"],
            "history": burnout_history  # <--- Mengirim list [10, 20, 30, ...]
        },
        "anxiety": {
            "score": latest["anxiety"],
            "change": latest["anxiety"] - previous["anxiety"],
            "history": anxiety_history
        },
        "depression": {
            "score": latest["depression"],
            "change": latest["depression"] - previous["depression"],
            "history": depression_history
        },
    }