defmodule MastodonBotEx.StreamingHandler do
  require Logger

  @doc "Process each line received from the stream"
  def process_line(line, account_id) do
    cond do
      String.starts_with?(line, "data: ") ->
        process_data(line, account_id)

      String.starts_with?(line, ":") ->
        handle_heartbeat()

      true ->
        handle_unknown_data(line)
    end
  end

  defp process_data(line, account_id) do
    line
    |> String.trim_leading("data:")
    |> String.trim()
    |> Jason.decode()
    |> handle_json_data(account_id)
  end

  defp handle_json_data({:ok, data}, account_id) do
    Logger.debug("Porocessing received status data.")
    result = MastodonBotEx.NotificationParser.extract_message_details(data)
    sender_id = result[:sender_id]
    channel_id = result[:channel_id]
    sender_name = result[:sender_name]
    notification_id = result[:notification_id]

    sendr_map = %{
      status_id: channel_id,
      user: sender_name
    }

    if sender_id != account_id do
      client = MastodonBotEx.StreamingClient.client()
      MastodonBotEx.Bot.dismiss_notification(client, notification_id)

      message_text = result.message_text
      lines = String.split(message_text, "\n", trim: true)

      Enum.each(lines, fn line ->
        case MastodonBotEx.RepoWatcher.RepoCommandParser.line(line) do
          {:ok, parsed_result, "", _, _, _} ->
            MastodonBotEx.RepoWatcher.RepoCommandHandler.handle_parsed_command(
              client,
              parsed_result,
              sendr_map
            )

          {:error, _reason, _, _, _, _} ->
            Logger.debug("Failed to parse line: #{line}")

            MastodonBotEx.Bot.post_status(
              client,
              "Sorry, I didn't understand: #{line}",
              channel_id
            )
        end
      end)

      Logger.debug("Message succesfully processed.")
      Process.sleep(:timer.seconds(2))
    else
      Logger.error("Data does match the current account ID.")
    end
  end

  defp handle_json_data({:error, reason}, _account_id) do
    Logger.info("Incomplete or malformed JSON. Reason: #{inspect(reason)}.")
  end

  defp handle_unknown_data(line) do
    Logger.debug("Unknown data received: #{line}.")
  end

  defp handle_heartbeat() do
    Logger.debug("Heartbeat data received.")
  end
end
