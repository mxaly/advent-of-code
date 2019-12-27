defmodule Day1Test do
  use ExUnit.Case
  doctest Day1

  test "run produces correct answer" do
    assert Day1.run() == 4_972_784
  end
end
