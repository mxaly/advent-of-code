defmodule Day16Test do
  @moduledoc false
  use ExUnit.Case
  doctest Day16

  test "calc_phases" do
    output = [2, 4, 1, 7, 6, 1, 7, 6]

    assert Day16.calc_phases(80_871_224_585_914_546_619_083_218_645_595, 100) |> Enum.take(8) ==
             output
  end

  test "works" do
    assert Day16.run_p1() == "69549155"
  end
end
