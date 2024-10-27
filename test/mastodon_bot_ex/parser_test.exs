defmodule MastodonBotEx.ParserTest do
  use ExUnit.Case, async: true

  # Test for the /github command
  test "github" do
    assert {:ok, [github: ["_user_", "_repo_", ["_tag1_", "_tag2_"]]], "", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /github _user_/_repo_ #_tag1_ #_tag2_"
             )
  end

  # Test for the /info command
  test "info" do
    assert {:ok, [info: ["_user_", "_repo_"]], "#_tag1_ #_tag2_", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /info _user_/_repo_ #_tag1_ #_tag2_"
             )
  end

  # Test for the /list_repos command
  test "list_repos" do
    assert {:ok, [:list_repos], " _user_/_repo_ #_tag1_ #_tag2_", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /list_repos _user_/_repo_ #_tag1_ #_tag2_"
             )
  end

  # Test for the /github_remove command
  test "github_remove" do
    assert {:ok, [github_remove: ["_user_", "_repo_"]], "", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /github_remove _user_/_repo_"
             )
  end

  # Test for the /tags_add command
  test "tags_add" do
    assert {:ok, [tags_add: ["_user_", "_repo_", ["_tag1_", "_tag2_"]]], "", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /tags_add _user_/_repo_ #_tag1_ #_tag2_"
             )
  end

  # Test for the /tags_remove command
  test "tags_remove" do
    assert {:ok, [tags_remove: ["_user_", "_repo_", ["_tag1_", "_tag2_"]]], "", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /tags_remove _user_/_repo_ #_tag1_ #_tag2_"
             )
  end

  # Test for the /help command
  test "help" do
    assert {:ok, [:help], "", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line("@test /help")
  end

  test "extra whitespace in github command" do
    assert {:ok, [github: ["_user_", "_repo_", ["_tag1_", "_tag2_"]]], "", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test    /github   _user_/_repo_   #_tag1_  #_tag2_"
             )
  end

  test "missing slash in repo" do
    assert {:error, _, _, _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /github _user_ #_tag1_ #_tag2_"
             )
  end

  test "too many slashes in repo" do
    assert {:error, _, _, _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /github _user_/_repo_/_extra_ #_tag1_ #_tag2_"
             )
  end

  test "missing hash in tags" do
    assert {:ok, [github: ["_user_", "_repo_", []]], "_tag1_ _tag2_", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /github _user_/_repo_ _tag1_ _tag2_"
             )
  end

  test "empty repo name" do
    assert {:error, _, _, _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /github _user_/ #_tag1_ #_tag2_"
             )
  end

  test "no tags after github or tags_add" do
    assert {:ok, [github: ["_user_", "_repo_", []]], "", _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line("@test /github _user_/_repo_")
  end

  test "invalid command" do
    assert {:error, _, _, _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /invalidcommand _user_/_repo_"
             )
  end

  test "repo name starting or ending with special characters" do
    assert {:error, _, _, _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line(
               "@test /github _user_/@repo #_tag1_ #_tag2_"
             )
  end

  test "command without arguments" do
    assert {:error, _, _, _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line("@test /github")
  end

  test "empty command or username without command" do
    assert {:error, _, _, _, _, _} =
             MastodonBotEx.RepoWatcher.RepoCommandParser.line("@test ")
  end
end
