import Config

# Configure the logger with the level set to log all messages
# Налаштовує логер із рівнем, встановленим на запис усіх повідомлень
config :logger,
  level: :all

# Configure Tesla to use Finch as the HTTP adapter with a specific name
# Налаштовує Tesla для використання Finch як HTTP-адаптера з заданим ім'ям
config :tesla,
  adapter: {Tesla.Adapter.Finch, name: MyFinch}
