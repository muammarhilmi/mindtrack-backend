from fastapi import APIRouter

from app.db.mongodb import db

router = APIRouter(
    tags=["Articles"]
)


@router.get("/articles")
def get_articles():

    collection = db[
        "articles"
    ]

    data = list(

        collection.find(
            {},
            {"_id": 0}
        )

    )

    data = sorted(

        data,

        key=lambda x:
        x.get(
            "popularity_score",
            0
        ),

        reverse=True
    )

    return data[:10]