import Config
Dotenv.load!()

# Load environment variables from .env file
# Завантажує змінні середовища з файлу .env

config :mastodon_bot_ex,
  domain: System.fetch_env!("MASTODON_DOMAIN"),
  token: System.fetch_env!("MASTODON_ACCESS_TOKEN")
  # Configure the Mastodon bot with the domain and access token from environment variables
  # Налаштовує бота Mastodon з доменом і токеном доступу зі змінних середовища
