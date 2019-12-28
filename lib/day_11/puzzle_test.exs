defmodule Day11Test do
  @moduledoc false
  use ExUnit.Case
  doctest Day11

  @image " █    ███  ████ █  █ █     ██  █  █ ███    \n █    █  █    █ █ █  █    █  █ █  █ █  █   \n █    █  █   █  ██   █    █    ████ █  █   \n █    ███   █   █ █  █    █ ██ █  █ ███    \n █    █    █    █ █  █    █  █ █  █ █ █    \n ████ █    ████ █  █ ████  ███ █  █ █  █   "

  test "works" do
    assert Day11.run() == @image
  end
end
