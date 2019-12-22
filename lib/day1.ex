defmodule Test do
  def moduleFuel(n) when n / 3 - 2 < 1 do 0 end

  def moduleFuel(n) do
    result = Float.floor(n / 3 - 2)
    result + Test.moduleFuel(result)
  end

  def calcFromFile(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.filter( fn x -> if(x != "") do x end end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&Test.moduleFuel/1)
    |> Enum.sum
    |> round
  end
end


# Test.calcFromFile("/Users/rafal/input.txt")
Test.moduleFuel(1969)