defmodule MastodonBotExTest do
  use ExUnit.Case
  doctest MastodonBotEx

  test "greets the world" do
    assert MastodonBotEx.hello() == :world
  end
end
