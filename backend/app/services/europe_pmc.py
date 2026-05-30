import re
from typing import Any

import requests

EUROPE_PMC_URL = "https://www.ebi.ac.uk/europepmc/webservices/rest/search"


def fetch_articles(keyword: str = "kesehatan mental", page_size: int = 10) -> list[dict[str, Any]]:
    params = {
        "query": keyword,
        "format": "json",
        "pageSize": page_size,
        "resultType": "core",
        "sort": "CITED desc",
    }
    response = requests.get(EUROPE_PMC_URL, params=params, timeout=30)
    response.raise_for_status()
    data = response.json()

    if "resultList" in data:
        return data["resultList"]["result"]
    return []


def _extract_pdf_url(item: dict[str, Any]) -> str:
    if "fullTextUrlList" not in item:
        return ""

    urls = item["fullTextUrlList"]["fullTextUrl"]
    for url_data in urls:
        link = url_data.get("url", "")
        if "pdf" in link.lower() or "download" in link.lower():
            return link
    return ""


def _normalize_abstract(abstract: str | None, strip_html: bool = False) -> str:
    text = abstract or ""
    if strip_html:
        text = re.sub(r"<.*?>", "", text)
    return text.replace("\n", " ").strip()


def clean_articles_data(
    articles: list[dict[str, Any]],
    *,
    strip_html: bool = False,
    default_abstract: str = "Abstract tidak tersedia",
    include_source: bool = False,
) -> list[dict[str, Any]]:
    clean_articles = []

    for item in articles:
        abstract = _normalize_abstract(item.get("abstractText"), strip_html=strip_html)

        article = {
            "title": item.get("title", "No Title"),
            "abstract": abstract if abstract else default_abstract,
            "author": item.get("authorString", "Unknown"),
            "journal": item.get("journalTitle", "Unknown"),
            "year": item.get("pubYear", ""),
            "citation_count": item.get("citedByCount", 0),
            "pdf_url": _extract_pdf_url(item),
        }

        if include_source:
            article["source"] = "Europe PMC"

        clean_articles.append(article)

    return clean_articles


def search_realtime(keyword: str, page_size: int = 5) -> list[dict[str, Any]]:
    raw = fetch_articles(keyword=keyword, page_size=page_size)
    return clean_articles_data(
        raw,
        strip_html=True,
        default_abstract="",
        include_source=False,
    )
