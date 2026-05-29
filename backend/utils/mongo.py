from pymongo import MongoClient


MONGO_URI = "mongodb+srv://mindtrack:mindtrack123@cluster0.68pvtdq.mongodb.net/?appName=Cluster0"


client = MongoClient(MONGO_URI)

db = client["mindtrack"]