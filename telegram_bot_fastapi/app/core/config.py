from dotenv import load_dotenv
import os

load_dotenv()

class Settings:
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_HOST = os.getenv("DB_HOST")
    DB_PORT = os.getenv("DB_PORT")
    DB_NAME = os.getenv("DB_NAME")
    DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

    TELEGRAM_BOT_TOKEN: str|None = os.getenv("TELEGRAM_BOT_TOKEN")
    TELEGRAM_URL = os.getenv("TELEGRAM_URL")
    TELEGRAM_BOT = f"{TELEGRAM_URL}{TELEGRAM_BOT_TOKEN}"
    FRONTEND = os.getenv("FRONTEND")


settings = Settings()

if not settings.DATABASE_URL:
    raise RuntimeError("DATABASE_URL not found in environment variables")