from flask import Flask
from .config.database import DB_CONFIG

def create_app():
    app = Flask(__name__)
    app.config.update(DB_CONFIG)
    return app
