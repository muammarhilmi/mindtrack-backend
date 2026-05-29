import requests
import re

from flask import Flask, jsonify

from flask_cors import CORS

from utils.mongo import db


app = Flask(__name__)

CORS(app)


# =====================================================
# HOME
# =====================================================

@app.route('/')

def home():

    return jsonify({

        "message": "MindTrack API Running"
    })


# =====================================================
# ARTICLES
# =====================================================

@app.route('/articles')

def get_articles():

    collection = db["popular_articles"]

    data = list(

        collection.find(
            {},
            {'_id':0}
        )
    )

    return jsonify(data)


# =====================================================
# WEEKLY TREND
# =====================================================

@app.route('/weekly-trend')

def weekly_trend():

    collection = db["weekly_trend"]

    data = list(

        collection.find(
            {},
            {'_id': 0}
        )
    )

    if len(data) < 2:

        return jsonify({
            "message": "Data trend tidak cukup"
        })

    latest = data[-1]

    previous = data[-2]

    result = {

        "burnout": {

            "score":
                latest['burnout'],

            "change":
                latest['burnout']
                -
                previous['burnout']
        },

        "anxiety": {

            "score":
                latest['anxiety'],

            "change":
                latest['anxiety']
                -
                previous['anxiety']
        },

        "depression": {

            "score":
                latest['depression'],

            "change":
                latest['depression']
                -
                previous['depression']
        }
    }

    return jsonify(result)

# =====================================================
# REALTIME SEARCH EUROPE PMC
# =====================================================

@app.route('/search-realtime/<keyword>')

def realtime_search(keyword):

    url = "https://www.ebi.ac.uk/europepmc/webservices/rest/search"

    params = {

        "query": keyword,

        "format": "json",

        "pageSize": 5,

        "resultType": "core",

        "sort": "CITED desc"
    }

    response = requests.get(
        url,
        params=params
    )

    data = response.json()

    results = []

    if 'resultList' in data:

        articles = data['resultList']['result']

        for item in articles:

            abstract = item.get(
                "abstractText",
                ""
            )

            if abstract is None:
                abstract = ""

            # HAPUS TAG HTML
            abstract = re.sub(
                r'<.*?>',
                '',
                abstract
            )

            abstract = abstract.replace(
                "\n",
                " "
            ).strip()

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

                "abstract": abstract,

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

                "pdf_url": pdf_url
            }

            results.append(article)

    return jsonify(results)
# =====================================================

if __name__ == "__main__":

    app.run(

        host='0.0.0.0',

        port=5000,

        debug=True
    )