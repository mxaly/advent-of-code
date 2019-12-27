defmodule Day2Test do
  use ExUnit.Case
  doctest Day2

  test "p1 works" do
    assert Day2.run_p1() == 3_790_689
  end

  test "p2 works" do
    assert Day2.run_p2() == 6533
  end
end
