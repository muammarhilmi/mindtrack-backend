from datetime import datetime

from bson import ObjectId
from fastapi import APIRouter, HTTPException

from app.db.mongodb import db
from app.schemas.journal import JournalCreate

router = APIRouter(tags=["Journal"])


# =====================================================
# CREATE JOURNAL
# =====================================================

@router.post("/journal")
def create_journal(data: JournalCreate):

    journal = {
        "user_id": data.user_id,
        "title": data.title,
        "content": data.content,
        "mood": data.mood,
        "created_at": datetime.utcnow()
    }

    result = db["journals"].insert_one(journal)

    return {
        "message": "Jurnal berhasil disimpan",
        "id": str(result.inserted_id)
    }


# =====================================================
# GET JOURNAL USER
# =====================================================

@router.get("/journal/{user_id}")
def get_journal(user_id: str):

    journals = []

    cursor = db["journals"].find(
        {"user_id": user_id}
    ).sort("created_at", -1)

    for item in cursor:
        journals.append({
            "id": str(item["_id"]),
            "user_id": item["user_id"],
            "title": item["title"],
            "content": item["content"],
            "mood": item["mood"],
            "created_at": item["created_at"]
        })

    return journals


# =====================================================
# DELETE JOURNAL
# =====================================================

@router.delete("/journal/{journal_id}")
def delete_journal(journal_id: str):

    if not ObjectId.is_valid(journal_id):
        raise HTTPException(
            status_code=400,
            detail="ID jurnal tidak valid"
        )

    result = db["journals"].delete_one({
        "_id": ObjectId(journal_id)
    })

    if result.deleted_count == 0:
        raise HTTPException(
            status_code=404,
            detail="Jurnal tidak ditemukan"
        )

    return {
        "message": "Jurnal berhasil dihapus"
    }