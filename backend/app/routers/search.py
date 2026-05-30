from fastapi import APIRouter

from app.services.europe_pmc import search_realtime

router = APIRouter(tags=["Search"])


@router.get("/search-realtime/{keyword}")
def realtime_search(keyword: str):
    return search_realtime(keyword)
