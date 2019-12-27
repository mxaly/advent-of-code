defmodule Day1 do
  def moduleFuel(n) when n / 3 - 2 < 1 do
    0
  end

  def moduleFuel(n) do
    result = Float.floor(n / 3 - 2)
    result + moduleFuel(result)
  end

  def calcFromFile(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.filter(fn x ->
      if(x != "") do
        x
      end
    end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&moduleFuel/1)
    |> Enum.sum()
    |> round
  end

  def run() do
    calcFromFile("lib/day_1/input.txt")
  end
end
