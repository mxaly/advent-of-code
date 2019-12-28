defmodule Day10Test do
  @moduledoc false
  use ExUnit.Case
  doctest Day10

  test "works" do
    assert Day10.run() == {{20, 18}, 280}
  end
end
