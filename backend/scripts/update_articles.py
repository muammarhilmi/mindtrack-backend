"""Refresh popular_articles collection from Europe PMC."""

from app.db.mongodb import db
from app.services.europe_pmc import clean_articles_data, fetch_articles


def main() -> None:
    collection = db["popular_articles"]

    articles = fetch_articles(keyword="kesehatan mental", page_size=10)
    clean_articles = clean_articles_data(articles, include_source=True)

    collection.delete_many({})
    if clean_articles:
        collection.insert_many(clean_articles)

    print("Artikel berhasil diupdate")


if __name__ == "__main__":
    main()
