defmodule FilesReader do
  def prepare_structure(input, x, y) do
    input
    |> Enum.chunk_every(x * y)
    # |> Enum.chunk_every(y)
  end

  def parse_file(path) do
    File.read!(path)
    |> String.split("")
    |> Enum.filter(fn(x) -> String.match?(x, ~r/\d+/) end)
    |> Enum.map(&String.to_integer/1)
  end

  def check(path) do
    {_, _, ones, twos} = parse_file(path)
    |> prepare_structure(25,6)
    |> Enum.map(fn(x) -> {x, Enum.count(x, fn(y) -> y == 0 end), Enum.count(x, fn(y) -> y == 1 end), Enum.count(x, fn(y) -> y == 2 end)} end)
    |> Enum.min_by(fn({_, zeros, _, _}) -> zeros end)
    ones * twos
  end

  def merge([0 | _rest]) do 0 end
  def merge([1 | _rest]) do 1 end
  def merge([x | []]) do x end
  def merge([_ | rest]) do merge(rest) end

  def run(path) do
    layers = parse_file(path)
    |> prepare_structure(25,6)
    [top | rest] = layers

    top
    |> Enum.with_index
    |> Enum.map(fn({el, index}) -> [el | Enum.map(rest, fn(layer) -> Enum.at(layer, index) end)] end)
    |> Enum.map(&merge/1)
    |> Enum.chunk_every(25)
    |> Enum.map(fn(x) -> Enum.join(x,  ",") end)
    |> Enum.join("\n")
    |> IO.puts
  end
end




# Test.run("day8-input.txt")
