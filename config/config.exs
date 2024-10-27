import Config

# Configure the logger with the level set to log all messages
# Налаштовує логер із рівнем, встановленим на запис усіх повідомлень
config :logger,
  level: :all

# Configure Tesla to use Finch as the HTTP adapter with a specific name
# Налаштовує Tesla для використання Finch як HTTP-адаптера з заданим ім'ям
config :tesla,
  adapter: {Tesla.Adapter.Finch, name: MyFinch}

config :mastodon_bot_ex, MastodonBotEx.Repo,
  database: "mastodon_bot.db",
  pool_size: 5

config :mastodon_bot_ex,
  ecto_repos: [MastodonBotEx.Repo]
