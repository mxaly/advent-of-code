defmodule Day1 do
  def moduleFuel(n) when n / 3 - 2 < 1 do
    0
  end

  def moduleFuel(n) do
    result = Float.floor(n / 3 - 2)
    result + moduleFuel(result)
  end

  def run() do
    FileReader.read_numbers("lib/day_1/input.txt")
    |> Enum.map(&moduleFuel/1)
    |> Enum.sum()
    |> round
  end
end
