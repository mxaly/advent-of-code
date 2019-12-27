defmodule Day7Test do
  use ExUnit.Case
  doctest Day7

  test "p1 works" do
    assert Day7.run_p1() == 75228
  end

  test "p2 works" do
    assert Day7.run_p2() == 79_846_026
  end
end
