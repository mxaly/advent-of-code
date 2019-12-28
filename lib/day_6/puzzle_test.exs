defmodule Day6Test do
  @moduledoc false
  use ExUnit.Case
  doctest Day6

  test "p1 works" do
    assert Day6.run_p1() == 387_356
  end

  test "p2 works" do
    assert Day6.run_p2() == 532
  end
end
