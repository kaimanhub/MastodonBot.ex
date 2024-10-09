defmodule MastodonBotEx.RepoWatcher.OpenSourceUpdates do
  use GenServer
  require Logger
  import Ecto.Query
  alias MastodonBotEx.Repo
  alias MastodonBotEx.Schema.RepoCheck
  alias MastodonBotEx.Schema.UserRepoCheck

  @check_interval :timer.hours(1)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_check()
    {:ok, nil}
  end

  @impl true
  def handle_info(:check_updates, _) do
    check_for_updates(load_repos())
    schedule_check()
    {:noreply, nil}
  end

  def check_repo_updates_by_name(repo) do
    case Repo.get_by(RepoCheck, repo: repo) do
      nil ->
        Logger.error("Repository #{repo} not found in watch list.")

      repo_check ->
        check_for_updates([repo_check])
    end
  end

  defp load_repos() do
    Repo.all(RepoCheck)
  end

  defp schedule_check do
    check_for_updates(load_repos())
    Process.send_after(self(), :check_updates, @check_interval)
  end

  @spec check_for_updates([RepoCheck.t()]) :: term()
  defp check_for_updates(repos) do
    Enum.each(repos, fn repo ->
      case get_latest_release(repo.repo) do
        {:ok, release} -> process_release(repo.repo, release)
        {:error, reason} -> Logger.error("Failed to get update for #{repo.repo}: #{reason}")
      end
    end)
  end

  defp process_release(repo, release) do
    repo_check = get_or_create_repo_check(repo)

    if should_post_update?(repo_check, release) do
      if repo_check.last_release_tag == "" do
        post_update(repo_check, release, true)
      else
        post_update(repo_check, release, false)
      end

      update_repo_check(repo_check, release)
    end
  end

  defp get_or_create_repo_check(repo) do
    case Repo.get_by(RepoCheck, repo: repo) do
      nil ->
        {:ok, repo_check} =
          Repo.insert(%RepoCheck{
            repo: repo,
            last_checked: ~N[1970-01-01 00:00:00],
            last_release_tag: "",
            tags: []
          })

        repo_check

      repo_check ->
        repo_check
    end
  end

  defp should_post_update?(repo_check, release) do
    repo_check.last_release_tag != release.tag_name
  end

  defp update_repo_check(repo_check, release) do
    repo_check
    |> RepoCheck.changeset(%{
      last_checked: NaiveDateTime.utc_now(),
      last_release_tag: release.tag_name
    })
    |> Repo.update()
  end

  defp get_latest_release(repo) do
    client = github_client()

    case Tesla.get(client, "/repos/#{repo}/releases/latest") do
      {:ok, %{status: 200, body: body}} ->
        {:ok,
         %{
           tag_name: body["tag_name"],
           name: body["name"],
           body: body["body"],
           published_at: NaiveDateTime.from_iso8601!(body["published_at"])
         }}

      {:ok, %{status: 404}} ->
        {:error, "No releases found for #{repo}"}

      {:ok, response} ->
        {:error, "Unexpected response: #{inspect(response)}"}

      {:error, error} ->
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  def post_update(repo_check, release, direct_only) do
    message = """
    📦 New release for #{repo_check.repo}!

    Version: #{release.tag_name}
    Name: #{release.name}

    #{String.slice(release.body || "", 0, 300)}...

    Check it out and contribute! 🚀
    #{get_repo_url(repo_check.repo)}

    """

    client = MastodonBotEx.StreamingClient.client()

    user_watches = Repo.all(from(uw in UserRepoCheck, where: uw.repo == ^repo_check.repo))

    Enum.each(user_watches, fn user_watch ->
      MastodonBotEx.Bot.post_direct_message(client, message, user_watch.user_acct)
    end)

    if !direct_only do
      MastodonBotEx.Bot.post_status(client, "#{message} #{format_tags(repo_check.tags)}")
    end
  end

  defp format_tags(tags) do
    tags
    |> Enum.map(&"##{&1}")
    |> Enum.join(" ")
  end

  defp get_repo_url(repo) do
    "https://github.com/#{repo}"
  end

  defp github_client do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://api.github.com"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"User-Agent", "MastodonBotEx"}]},
      {Tesla.Middleware.BearerAuth, token: github_token()}
    ]

    Tesla.client(middleware)
  end

  defp github_token do
    Application.fetch_env!(:mastodon_bot_ex, :github_token)
  end
end
