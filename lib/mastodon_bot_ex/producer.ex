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

    {:producer, {:queue.new(), "", 0}}
  end

  @impl GenStage
  @doc "Handle demand for events from consumers"
  def handle_demand(incoming_demand, {queue, acc, pending_demand}) do
    demand = incoming_demand + pending_demand

    dispatch_events(queue, demand, acc, [])
  end

  @impl GenStage
  @doc "Handle incoming data from the stream, split it into events"
  def handle_info({_, {_, {:error, %Mint.TransportError{reason: :closed}}}}, state) do
    {:stop, {:shutdown, :transport_closed}, state}
  end

  def handle_info({_, {:data, data}}, {queue, acc, pending_demand}) do
    acc = acc <> data

    case :binary.split(acc, "\n\n") do
      [":thump\n"] ->
        {:noreply, [":thump"], {queue, "", pending_demand - 1}}

      [":)\n"] ->
        {:noreply, [":thump"], {queue, "", pending_demand - 1}}

      [messages, extra_acc] ->
        updated_queue =
          Enum.reduce(String.split(messages, "\n", trim: true), queue, fn message, internal_acc ->
            :queue.in(message, internal_acc)
          end)

        dispatch_events(updated_queue, pending_demand, extra_acc, [])

      _ ->
        {:noreply, [], {queue, acc, pending_demand}}
    end
  end

  @impl GenStage
  def handle_info({_, {:error, %Mint.TransportError{reason: :closed}}}, state) do
    # TODO: need to handle handling reconnection here
    {:noreply, [], state}
  end

  defp dispatch_events(queue, 0, acc, events) do
    {:noreply, Enum.reverse(events), {queue, acc, 0}}
  end

  defp dispatch_events(queue, demand, acc, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        dispatch_events(queue, demand - 1, acc, [event | events])

      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, acc, demand}}
    end
  end
end
