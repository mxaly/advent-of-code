defmodule Day14Test do
  @moduledoc false
  use ExUnit.Case
  doctest Day14

  test "part 1 works" do
    assert Day14.run_p1() == 598_038
  end

  test "part 2 works" do
    assert Day14.run_p2() == 2_269_325
  end
end
