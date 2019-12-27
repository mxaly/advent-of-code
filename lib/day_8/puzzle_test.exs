defmodule Day8Test do
  use ExUnit.Case
  doctest Day8

  test "works" do
    out =
      "████  ██    ██ █  █ ████ \n█    █  █    █ █  █    █ \n███  █       █ █  █   █  \n█    █ ██    █ █  █  █   \n█    █  █ █  █ █  █ █    \n█     ███  ██   ██  ████ "

    assert Day8.run() == out
  end
end
