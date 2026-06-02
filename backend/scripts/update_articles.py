from bs4 import BeautifulSoup
import requests

from app.db.mongodb import db

BASE_URL = "https://www.alodokter.com"

KEYWORDS = [
    "kesehatan mental",
    "depresi",
    "anxiety",
    "burnout",
    "stres"
]

MENTAL_KEYWORDS = [
    "mental",
    "depresi",
    "anxiety",
    "burnout",
    "stres",
    "stress",
    "cemas",
    "psikolog",
    "psikologi"
]


def scrape_articles():

    headers = {
        "User-Agent":
        "Mozilla/5.0"
    }

    articles = []

    for keyword in KEYWORDS:

        url = (
            f"https://www.alodokter.com/search"
            f"?s={keyword.replace(' ','+')}"
        )

        response = requests.get(
            url,
            headers=headers
        )

        soup = BeautifulSoup(
            response.text,
            "html.parser"
        )

        cards = soup.find_all(
            "card-post-index"
        )

        for card in cards:

            title = card.get("title")
            category = card.get("category")
            description = card.get(
                "short-description"
            )
            image_url = card.get(
                "image-url"
            )

            article_url = (
                BASE_URL +
                card.get(
                    "url-path",
                    ""
                )
            )

            # skip data kosong
            if (
                not title or
                not description or
                not image_url
            ):
                continue

            articles.append({

                "title":
                    title,

                "category":
                    category or "",

                "description":
                    description,

                "image_url":
                    image_url,

                "url":
                    article_url
            })

    return articles


def main():

    collection = db["articles"]

    data = scrape_articles()

    # =====================
    # HAPUS DUPLIKAT
    # =====================

    unique = {}

    for article in data:

        unique[
            article["title"]
        ] = article

    clean_articles = list(
        unique.values()
    )

    # =====================
    # FILTER MENTAL HEALTH
    # =====================

    filtered_articles = []

    for article in clean_articles:

        text = (
            article["title"] + " " +
            article["description"]
        ).lower()

        score = 0

        for keyword in MENTAL_KEYWORDS:
            score += (
                text.count(keyword) * 10
            )

        # hanya simpan artikel yang
        # benar-benar mengandung
        # keyword kesehatan mental
        if score > 0:

            article[
                "popularity_score"
            ] = score

            filtered_articles.append(
                article
            )

    # =====================
    # SORT BERDASARKAN SCORE
    # =====================

    filtered_articles.sort(
        key=lambda x: x[
            "popularity_score"
        ],
        reverse=True
    )

    # =====================
    # SIMPAN KE MONGODB
    # =====================

    collection.delete_many({})

    if filtered_articles:

        collection.insert_many(
            filtered_articles
        )

    print(
        f"Artikel berhasil diperbarui ({len(filtered_articles)} data)"
    )


if __name__ == "__main__":
    main()