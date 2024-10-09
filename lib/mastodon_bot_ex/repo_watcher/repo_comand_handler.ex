defmodule MastodonBotEx.RepoWatcher.RepoCommandHandler do
  require Logger
  alias MastodonBotEx.Schema.{RepoCheck}
  alias MastodonBotEx.{Repo, Bot}
  alias MastodonBotEx.RepoWatcher.OpenSourceUpdates
  alias MastodonBotEx.Schema.UserRepoCheck

  def handle_parsed_command(client, parsed_result, sender_info) do
    case parsed_result do
      [{:github, repo_and_tags}] ->
        [owner, repo_name | tags] = repo_and_tags
        repo = "#{owner}/#{repo_name}"
        tags = List.flatten(tags)
        handle_add_github(client, repo, tags, sender_info)

      [{:github_remove, repo_and_tags}] ->
        [owner, repo_name | _] = repo_and_tags
        repo = "#{owner}/#{repo_name}"
        handle_github_remove(client, repo, sender_info)

      [{:tags_add, repo_and_tags}] ->
        [owner, repo_name | tags] = repo_and_tags
        repo = "#{owner}/#{repo_name}"
        tags = List.flatten(tags)
        handle_tags_add(client, repo, tags, sender_info)

      [{:tags_remove, repo_and_tags}] ->
        [owner, repo_name | tags] = repo_and_tags
        repo = "#{owner}/#{repo_name}"
        tags = List.flatten(tags)
        handle_tags_remove(client, repo, tags, sender_info)

      [{:info, [owner, repo_name]}] ->
        repo = "#{owner}/#{repo_name}"
        handle_info_repo(client, repo, sender_info)

      [:help] ->
        handle_help(
          client,
          sender_info
        )

      _ ->
        Logger.debug("Unknown command parsed: #{inspect(parsed_result)}")

        MastodonBotEx.Bot.post_status(client, "Unknown command.", sender_info)
    end
  end

  defp handle_add_github(client, repo, tags, sender_info) do
    repo_check = Repo.get_by(RepoCheck, repo: repo)

    if repo_check do
      new_tags = Enum.uniq(repo_check.tags ++ tags)

      if new_tags != repo_check.tags do
        changeset = RepoCheck.changeset(repo_check, %{tags: new_tags})
        Repo.update!(changeset)
      end
    else
      # Create a new RepoCheck entry
      repo_check = %RepoCheck{
        repo: repo,
        last_checked: ~N[1970-01-01 00:00:00],
        last_release_tag: "",
        tags: tags
      }

      Repo.insert!(repo_check)
    end

    user_repo_watch_changeset =
      UserRepoCheck.changeset(%UserRepoCheck{}, %{
        user_acct: sender_info.user,
        repo: repo
      })

    case Repo.insert(user_repo_watch_changeset) do
      {:ok, _user_repo_watch} ->
        message = "You have started watching repository #{repo}."
        Bot.post_direct_message(client, message, sender_info.user)

      {:error, changeset} ->
        reason =
          changeset.errors
          |> Keyword.get(:repo_error, {"Unknown error appeared, try again latter"})
          |> elem(0)

        message = "#{reason}. Repo: #{repo}"

        Bot.post_status(client, message, sender_info.status_id)
    end

    OpenSourceUpdates.check_repo_updates_by_name(repo)
  end

  def handle_github_remove(client, repo, sender_info) do
    case Repo.get_by(RepoCheck, repo: repo) do
      nil ->
        Bot.post_status(
          client,
          "Repository #{repo} not found watch list. #{sender_info.user}",
          sender_info.status_id
        )

      repo_check ->
        Repo.delete(repo_check)

        Bot.post_status(
          client,
          "Repository #{repo} has been removed from watch list. #{sender_info.user}",
          sender_info.status_id
        )
    end
  end

  defp handle_tags_add(client, repo, tags, sender_info) do
    case Repo.get_by(RepoCheck, repo: repo) do
      nil ->
        Bot.post_status(
          client,
          "Repository #{repo} not found in watch list. #{sender_info.user}",
          sender_info.status_id
        )

      repo_check ->
        new_tags = Enum.uniq(repo_check.tags ++ tags) |> Enum.take(5)
        changeset = RepoCheck.changeset(repo_check, %{tags: new_tags})

        case Repo.update(changeset) do
          {:ok, _updated_repo_check} ->
            Bot.post_status(
              client,
              "Tags #{format_tags(tags)} have been added to #{repo}. #{sender_info.user}",
              sender_info.status_id
            )

          {:error, changeset} ->
            Bot.post_status(
              client,
              "Failed to add tags: #{inspect(changeset.errors)} #{sender_info.user}",
              sender_info.status_id
            )
        end
    end
  end

  defp handle_tags_remove(client, repo, tags, sender_info) do
    case Repo.get_by(RepoCheck, repo: repo) do
      nil ->
        Bot.post_status(
          client,
          "Repository #{repo} not found in watch list. #{sender_info.user}",
          sender_info.status_id
        )

      repo_check ->
        new_tags = Enum.uniq(repo_check.tags -- tags)
        changeset = RepoCheck.changeset(repo_check, %{tags: new_tags})

        case Repo.update(changeset) do
          {:ok, _updated_repo_check} ->
            Bot.post_status(
              client,
              "Tags #{format_tags(tags)} have been removed from #{repo}. #{sender_info.user}",
              sender_info.status_id
            )

          {:error, changeset} ->
            Bot.post_status(
              client,
              "Failed to add tags: #{inspect(changeset.errors)} #{sender_info.user}",
              sender_info.status_id
            )
        end
    end
  end

  defp handle_info_repo(client, repo, sender_info) do
    case Repo.get_by(RepoCheck, repo: repo) do
      nil ->
        Bot.post_status(
          client,
          "Repository #{repo} not found in watch list. #{sender_info.user}",
          sender_info.status_id
        )

      repo_check ->
        info_message = """
        Repository Information:
          Repo: #{repo_check.repo}
              Last Checked: #{format_datetime(repo_check.last_checked)}
              Last Release Tag: #{repo_check.last_release_tag || "N/A"}
              Tags: #{format_tags(repo_check.tags)}
        #{sender_info.user}
        """

        Bot.post_status(client, info_message, sender_info.status_id)
    end
  end

  defp handle_help(client, sender_info) do
    help_message = """
    **Available Commands:**

    - `/github <owner>/<repo> #tag1 #tag2 ...`: Add GitHub repository with tags.
    - `/github_remove <owner>/<repo>`: Remove GitHub repository.
    - `/tags_add <owner>/<repo> #tag1 #tag2 ...`: Add tags to a repository.
    - `/tags_remove <owner>/<repo> #tag1 #tag2 ...`: Remove tags from a repository.
    - `/info <owner>/<repo>`: Show repository information.
    - `/help`: Show this help message.
     #{sender_info.user}
    """

    Bot.post_status(client, help_message, sender_info.status_id)
  end

  # Helper functions
  defp format_datetime(nil), do: "Never"
  defp format_datetime(datetime), do: NaiveDateTime.to_string(datetime)

  defp format_tags([]), do: "None"
  defp format_tags(tags), do: tags |> Enum.map(&"##{&1}") |> Enum.join(" ")
end
