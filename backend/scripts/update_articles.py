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

            articles.append({

                "title":
                    card.get("title"),

                "category":
                    card.get("category"),

                "description":
                    card.get(
                        "short-description"
                    ),

                "image_url":
                    card.get(
                        "image-url"
                    ),

                "url":
                    BASE_URL +
                    card.get(
                        "url-path",
                        ""
                    )
            })

    return articles


def main():

    collection = db["articles"]

    data = scrape_articles()

    # cleaning

    unique = {}

    for article in data:

        unique[
            article["title"]
        ] = article

    clean_articles = list(
        unique.values()
    )

    # popularity score

    for article in clean_articles:

        article[
            "popularity_score"
        ] = (

            len(
                article["title"]
            )

            +

            len(
                article["description"]
            ) // 20

        )

    collection.delete_many({})

    collection.insert_many(
        clean_articles
    )

    print(
        "Artikel berhasil diperbarui"
    )


if __name__ == "__main__":
    main()