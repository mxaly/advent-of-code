defmodule Day3Test do
  @moduledoc false

  use ExUnit.Case
  doctest Day3

  test "it works" do
    assert Day3.run() == 48_054
  end
end
