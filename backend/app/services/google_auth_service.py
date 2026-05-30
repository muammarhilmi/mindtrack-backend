from google.auth.transport import requests as google_requests
from google.oauth2 import id_token

from app.core.config import settings


def verify_google_id_token(token: str) -> dict:
    audiences = settings.google_audiences
    if not audiences:
        raise ValueError("GOOGLE_CLIENT_ID belum dikonfigurasi di backend")

    request = google_requests.Request()
    idinfo = id_token.verify_oauth2_token(token, request)

    if idinfo.get("aud") not in audiences:
        raise ValueError("Google token audience tidak valid")

    issuer = idinfo.get("iss", "")
    if issuer not in {"accounts.google.com", "https://accounts.google.com"}:
        raise ValueError("Google token issuer tidak valid")

    if not idinfo.get("email"):
        raise ValueError("Email tidak tersedia dari Google")

    return idinfo
