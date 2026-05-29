import requests

from utils.mongo import db


# =====================================================
# COLLECTION
# =====================================================

collection = db["popular_articles"]


# =====================================================
# FETCH ARTICLES
# =====================================================

def fetch_articles(

    keyword="kesehatan mental",

    page_size=10
):

    url = "https://www.ebi.ac.uk/europepmc/webservices/rest/search"

    params = {

        "query": keyword,

        "format": "json",

        "pageSize": page_size,

        "resultType": "core",

        "sort": "CITED desc"
    }

    response = requests.get(
        url,
        params=params
    )

    data = response.json()

    if 'resultList' in data:

        return data['resultList']['result']

    return []


# =====================================================
# CLEANING
# =====================================================

def clean_articles_data(articles):

    clean_articles = []

    for item in articles:

        abstract = item.get(
            "abstractText",
            ""
        )

        if abstract is None:

            abstract = ""

        abstract = abstract.replace(
            "\n",
            " "
        ).strip()


        # PDF URL

        pdf_url = ""

        if 'fullTextUrlList' in item:

            urls = item[
                'fullTextUrlList'
            ]['fullTextUrl']

            for url_data in urls:

                link = url_data.get(
                    "url",
                    ""
                )

                if (

                    "pdf" in link.lower()

                    or

                    "download" in link.lower()

                ):

                    pdf_url = link

                    break


        article = {

            "title": item.get(
                "title",
                "No Title"
            ),

            "abstract": abstract
            if abstract != ""
            else "Abstract tidak tersedia",

            "author": item.get(
                "authorString",
                "Unknown"
            ),

            "journal": item.get(
                "journalTitle",
                "Unknown"
            ),

            "year": item.get(
                "pubYear",
                ""
            ),

            "citation_count": item.get(
                "citedByCount",
                0
            ),

            "pdf_url": pdf_url,

            "source": "Europe PMC"
        }

        clean_articles.append(article)

    return clean_articles


# =====================================================
# MAIN
# =====================================================

articles = fetch_articles(

    keyword="kesehatan mental",

    page_size=10
)

clean_articles = clean_articles_data(
    articles
)


# HAPUS DATA LAMA

collection.delete_many({})


# INSERT DATA BARU

collection.insert_many(clean_articles)

print("✅ Artikel berhasil diupdate")