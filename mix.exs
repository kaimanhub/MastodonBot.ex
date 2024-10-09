defmodule MastodonBotEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :mastodon_bot_ex,
      version: "1.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MastodonBotEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.12"},
      {:jason, "~> 1.4"},
      {:dotenv, "~> 3.1"},
      {:finch, "~> 0.18"},
      {:floki, "~> 0.36"},
      {:gen_stage, "~> 1.2"},
      {:ecto_sql, "~> 3.12"},
      {:ecto_sqlite3, "~> 0.17"},
      {:nimble_parsec, "~> 1.4"}
    ]
  end
end
