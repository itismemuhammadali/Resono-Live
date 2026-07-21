from flask import Flask, jsonify
from flask.json.provider import DefaultJSONProvider
from flask_cors import CORS
from datetime import datetime, timezone
from config import settings
from firebase_config import get_firebase_app

from routes.users import users_bp
from routes.posts import posts_bp
from routes.discussions import discussions_bp
from routes.chat import chat_bp
from routes.performances import performances_bp
from routes.search import search_bp
from routes.notifications import notifications_bp
from routes.artists import artists_bp
from routes.agora import agora_bp
from routes.stripe_payments import stripe_bp
from routes.admin import admin_bp
from routes.campaigns import campaigns_bp


class DateTimeJSONProvider(DefaultJSONProvider):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super().default(obj)


def create_app():
    app = Flask(__name__)
    app.json_provider_class = DateTimeJSONProvider
    app.json = DateTimeJSONProvider(app)

    CORS(
        app,
        origins=settings.CORS_ORIGINS + [r".*"],
        supports_credentials=True,
        allow_headers=["Content-Type", "Authorization"],
        expose_headers=["Content-Type"],
        methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    )

    get_firebase_app()
    print(f"[VibeSwipe API] Running on {settings.HOST}:{settings.PORT}")

    app.register_blueprint(users_bp)
    app.register_blueprint(posts_bp)
    app.register_blueprint(discussions_bp)
    app.register_blueprint(chat_bp)
    app.register_blueprint(performances_bp)
    app.register_blueprint(search_bp)
    app.register_blueprint(notifications_bp)
    app.register_blueprint(artists_bp)
    app.register_blueprint(agora_bp)
    app.register_blueprint(stripe_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(campaigns_bp)

    @app.before_request
    def handle_options():
        from flask import request, make_response
        if request.method == "OPTIONS":
            return make_response("", 200)

    @app.route("/")
    def root():
        return jsonify({"status": "ok", "service": "VibeSwipe API", "version": "1.0.0"})

    @app.route("/health")
    def health():
        return jsonify({"status": "healthy"})

    return app


app = create_app()

if __name__ == "__main__":
    app.run(host=settings.HOST, port=settings.PORT, debug=settings.DEBUG, threaded=True)
