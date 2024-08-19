defmodule MastodonBotEx.NotificationParser do
  @doc "Extract message details from the notification data"
  def extract_message_details(data) do
    sender_id = get_in(data, ["account", "id"])
    sender_name = "@" <> get_in(data, ["account", "acct"])
    channel_id = get_in(data, ["status", "id"])
    notification_id = get_in(data, ["id"])
    raw_message_text = get_in(data, ["status", "content"])

    message_text =
      if raw_message_text do
        {:ok, document} = Floki.parse_fragment(raw_message_text)
        Floki.text(document)
      else
        ""
      end

    %{
      sender_id: sender_id,
      message_text: message_text,
      channel_id: channel_id,
      sender_name: sender_name,
      notification_id: notification_id
    }
  end
end
