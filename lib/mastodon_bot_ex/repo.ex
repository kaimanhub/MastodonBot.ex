defmodule MastodonBotEx.Repo do
  use Ecto.Repo,
    otp_app: :mastodon_bot_ex,
    adapter: Ecto.Adapters.SQLite3
end
