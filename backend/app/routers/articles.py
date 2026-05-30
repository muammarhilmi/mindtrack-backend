from fastapi import APIRouter

router = APIRouter(tags=["Articles"])


@router.get("/articles")
def get_articles():
    from app.db.mongodb import db

    collection = db["popular_articles"]
    return list(collection.find({}, {"_id": 0}))
