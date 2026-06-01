from fastapi import APIRouter
import requests
from bs4 import BeautifulSoup

router = APIRouter(tags=["Search"])

@router.get("/search-realtime/{keyword}")
def search_realtime(keyword: str):

    url = f"https://www.alodokter.com/search?s={keyword}"

    headers = {
        "User-Agent": "Mozilla/5.0"
    }

    response = requests.get(
        url,
        headers=headers,
        timeout=20
    )

    soup = BeautifulSoup(
        response.text,
        "html.parser"
    )

    results = []

    cards = soup.find_all(
        "card-post-index"
    )

    for card in cards:

        title = card.get("title", "")
        description = card.get(
            "short-description",
            ""
        )
        image = card.get(
            "image-url",
            ""
        )

        path = card.get(
            "url-path",
            ""
        )

        article_url = (
            "https://www.alodokter.com"
            + path
        )

        category = card.get(
            "category",
            ""
        )

        results.append({
            "title": title,
            "description": description,
            "image": image,
            "url": article_url,
            "category": category
        })

    return results