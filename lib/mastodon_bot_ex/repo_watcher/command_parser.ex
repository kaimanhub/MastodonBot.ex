defmodule MastodonBotEx.RepoWatcher.RepoCommandParser do
  import NimbleParsec

  arg_tag =
    ignore(ascii_string([?\s], min: 0))
    |> ignore(string("#"))
    |> utf8_string([not: ?\s], min: 1)

  tags =
    repeat(arg_tag)
    |> reduce({Function, :identity, []})

  repo_part = utf8_string([?a..?z, ?A..?Z, ?0..?9, ?_, ?., ?-], min: 1)

  repo =
    ignore(ascii_string([?\s], min: 1))
    |> concat(repo_part)
    |> ignore(string("/"))
    |> concat(repo_part)
    |> ignore(choice([ascii_char([?\s]), eos()]))

  not_slash = ignore(ascii_string([not: ?/], min: 0))

  # /github <repo> <tag1> <tag2>: Add GitHub repository to the watch list with tags
  gh =
    ignore(string("/github"))
    |> concat(repo)
    |> concat(tags)
    |> tag(:github)

  # /github_remove <repo>: Remove GitHub repository from the watch list
  github_remove =
    ignore(string("/github_remove"))
    |> concat(repo)
    |> tag(:github_remove)

  # /list_repos: List all repositories
  list_repos =
    ignore(string("/list_repos"))
    |> replace(:list_repos)

  # /tags_add <repo> <tag1> <tag2> ... : Add tags for a repository
  tags_add =
    ignore(string("/tags_add"))
    |> concat(repo)
    |> concat(tags)
    |> tag(:tags_add)

  # /tags_remove <repo> <tag1> <tag2> ... : Remove tags from a repository
  tags_remove =
    ignore(string("/tags_remove"))
    |> concat(repo)
    |> concat(tags)
    |> tag(:tags_remove)

  # /info <repo>: Show information about a repository
  info_repo =
    ignore(string("/info"))
    |> concat(repo)
    |> tag(:info)

  # /help: Show help message
  help =
    ignore(string("/help"))
    |> replace(:help)

  defparsec(
    :line,
    not_slash
    |> choice([
      gh,
      github_remove,
      list_repos,
      tags_add,
      tags_remove,
      info_repo,
      help
    ])
  )
end
