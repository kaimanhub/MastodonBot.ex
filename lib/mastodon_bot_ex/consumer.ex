defmodule MastodonBotEx.Consumer do
  use GenStage

  @doc "Start the GenStage consumer with the given account ID"
  def start_link(account_id) do
    GenStage.start_link(__MODULE__, account_id)
  end

  @impl GenStage
  @doc "Initialize the consumer and subscribe to the producer with a maximum demand of 1 event"
  def init(account_id) do
    {:consumer, account_id, subscribe_to: [{MastodonBotEx.Producer, max_demand: 1}]}
  end

  @impl GenStage
  @doc "Handle incoming events by processing each event with the StreamingHandler"
  def handle_events(events, _from, account_id) do
    events
    |> Enum.each(&MastodonBotEx.StreamingHandler.process_line(&1, account_id))

    {:noreply, [], account_id}
  end
end

defmodule MastodonBotEx.ConsumerSupervisor do
  use Supervisor

  @doc "Initialize the supervisor with three consumers, each with the same account ID"
  def init(account_id) do
    Supervisor.init(
      [
        Supervisor.child_spec({MastodonBotEx.Consumer, account_id}, id: :c1),
        Supervisor.child_spec({MastodonBotEx.Consumer, account_id}, id: :c2),
        Supervisor.child_spec({MastodonBotEx.Consumer, account_id}, id: :c3)
      ],
      strategy: :one_for_one
    )
  end

  @doc "Start the supervisor and retrieve the account ID from the bot to initialize the consumers"
  def start_link(_) do
    client = MastodonBotEx.StreamingClient.client()
    %{account_id: account_id} = MastodonBotEx.Bot.get_account_id(client)

    Supervisor.start_link(
      __MODULE__,
      account_id
    )
  end
end
