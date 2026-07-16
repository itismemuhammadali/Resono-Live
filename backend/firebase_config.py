import os
import firebase_admin
from firebase_admin import credentials, firestore, auth
from config import settings


_app = None


def get_firebase_app():
    global _app
    if _app is not None:
        return _app

    cred_path = settings.GOOGLE_APPLICATION_CREDENTIALS
    if os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        _app = firebase_admin.initialize_app(cred, {"projectId": settings.FIREBASE_PROJECT_ID})
    else:
        _app = firebase_admin.initialize_app(options={"projectId": settings.FIREBASE_PROJECT_ID})

    return _app


def get_firestore_client():
    get_firebase_app()
    return firestore.client()


def verify_firebase_token(id_token: str) -> dict:
    get_firebase_app()
    return auth.verify_id_token(id_token)
