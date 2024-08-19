defmodule MastodonBotEx.Producer do
  use GenStage

  def start_link(state) do
    GenStage.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl GenStage
  @doc "Initialize the producer and start streaming user notifications"
  def init(_) do
    %{status: 200} =
      MastodonBotEx.StreamingClient.stream_user_notifications()

    {:producer, :ok}
  end

  @impl GenStage
  @doc "Handle demand for events from consumers"
  def handle_demand(_number_events, _stream) do
    {:noreply, [], :ok}
  end

  @impl GenStage
  @doc "Handle incoming data from the stream, split it into events"
  def handle_info({_, {:data, data}}, _state) do
    events = String.split(data, "\n", trim: true)

    {:noreply, events, :ok}
  end
end
