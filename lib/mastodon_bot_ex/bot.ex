defmodule MastodonBotEx.Bot do
  @doc "Get account information using the provided client"
  def get_account_info(client) do
    Tesla.get!(client, "/accounts/verify_credentials")
  end

  @doc "Extract and return the account ID from the account information"
  def get_account_id(client) do
    %{status: 200, body: body} = get_account_info(client)
    %{account_id: body["id"]}
  end

  defp do_post(client, params) do
    Tesla.post!(
      client,
      "/statuses",
      params
    )
  end

  @doc "Post a status with a private visibility"
  def post_status(client, status_message, nil) do
    params = %{
      "status" => status_message,
      "visibility" => "private"
    }

    do_post(client, params)
  end

  def post_status(client, status_message, status_is) do
    params = %{
      "status" => status_message,
      "visibility" => "direct",
      "in_reply_to_id" => status_is
    }

    do_post(client, params)
  end

  @doc "Dismiss a notification by its ID"
  def dismiss_notification(client, id) do
    Tesla.post!(client, "/notifications/#{id}/dismiss", %{})
  end
end
