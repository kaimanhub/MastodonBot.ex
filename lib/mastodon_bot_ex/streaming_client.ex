defmodule MastodonBotEx.StreamingClient do
  require Logger
  use Tesla

  @adapter_opts [
    receive_timeout: 90_000,
    keepalive: true,
    response: :stream
  ]

  @doc "Function to stream user notifications"
  def stream_user_notifications do
    url = "/streaming/user/notification"

    Logger.info("On start of user stream")
    get!(client(), url, opts: [adapter: @adapter_opts])
  end

  @spec client() :: Tesla.Client.t()
  @doc "Create a Tesla client with the necessary middleware"
  def client do
    domain = Application.fetch_env!(:mastodon_bot_ex, :domain)
    base_url = "https://#{domain}/api/v1"
    token = Application.fetch_env!(:mastodon_bot_ex, :token)

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers,
       [
         {"Connection", "keep-alive"}
       ]},
      {Tesla.Middleware.BearerAuth, token: token},
      Tesla.Middleware.DecodeJson,
      Tesla.Middleware.Logger,
      Tesla.Middleware.FormUrlencoded
    ]

    Tesla.client(middleware)
  end
end
