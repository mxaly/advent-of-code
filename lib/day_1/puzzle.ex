defmodule Day1 do
  @moduledoc false

  def module_fuel(n) when n / 3 - 2 < 1 do
    0
  end

  def module_fuel(n) do
    result = Float.floor(n / 3 - 2)
    result + module_fuel(result)
  end

  def run() do
    FileReader.read_numbers("lib/day_1/input.txt")
    |> Enum.map(&module_fuel/1)
    |> Enum.sum()
    |> round
  end
end
