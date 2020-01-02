defmodule Day16Test do
  @moduledoc false
  use ExUnit.Case
  doctest Day16

  test "p1 works" do
    assert Day16.run_p1() == "69549155"
  end

  test "p2 works" do
    assert Day16.run_p2() == "83253465"
  end
end
