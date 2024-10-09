defmodule MastodonBotEx.Application do
  use Application

  @doc "Start the application with a supervisor managing Finch and a nested supervisor"
  @impl Application
  def start(_type, _args) do
    Supervisor.start_link(
      [
        {Finch, name: MyFinch},
        MastodonBotEx.Repo,
        MastodonBotEx.RepoWatcher.OpenSourceUpdates,
        MastodonBotEx.NestedSupervisor
      ],
      strategy: :one_for_one
    )
  end
end

defmodule MastodonBotEx.NestedSupervisor do
  use Supervisor

  @doc "Initialize the nested supervisor with Producer and ConsumerSupervisor"
  def init(:ok) do
    Supervisor.init(
      [
        MastodonBotEx.Producer,
        MastodonBotEx.ConsumerSupervisor
      ],
      strategy: :rest_for_one
    )
  end

  @doc "Start the nested supervisor"
  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok)
  end
end
