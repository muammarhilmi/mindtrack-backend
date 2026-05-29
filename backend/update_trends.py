from pytrends.request import TrendReq

from utils.mongo import db

import pandas as pd

from datetime import datetime


# =====================================================
# GOOGLE TRENDS
# =====================================================

pytrends = TrendReq(

    hl='en-US',

    tz=420
)


kw_list = [

    "burnout",

    "depression",

    "anxiety"
]


# =====================================================
# FETCH DATA
# =====================================================

pytrends.build_payload(

    kw_list,

    timeframe='today 3-m',

    geo='ID'
)


trend_data = pytrends.interest_over_time()


# =====================================================
# CLEANING
# =====================================================

trend_data = trend_data.drop(

    labels=['isPartial'],

    axis='columns'
)


trend_data = trend_data.reset_index()


trend_data.columns = [

    'date',

    "burnout",

    "depression",

    "anxiety"
]


trend_data['api_updated_at'] = datetime.now()


# =====================================================
# MONGODB
# =====================================================

collection = db["weekly_trend"]


records = trend_data.to_dict(
    'records'
)


collection.delete_many({})

collection.insert_many(records)

print("✅ Weekly trend berhasil diupdate")