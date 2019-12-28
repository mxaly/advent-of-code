defmodule Day3 do
  @moduledoc false

  def get_path(path, []) do
    path
  end

  def get_path(path, [move | rest_moves]) do
    rest_length = String.length(move) - 1
    [{x, y} | _rest] = path

    path =
      case move do
        <<"R", rest::binary-size(rest_length)>> ->
          Enum.reduce(1..String.to_integer(rest), path, fn i, path -> [{x, y + i} | path] end)

        <<"L", rest::binary-size(rest_length)>> ->
          Enum.reduce(1..String.to_integer(rest), path, fn i, path -> [{x, y - i} | path] end)

        <<"U", rest::binary-size(rest_length)>> ->
          Enum.reduce(1..String.to_integer(rest), path, fn i, path -> [{x + i, y} | path] end)

        <<"D", rest::binary-size(rest_length)>> ->
          Enum.reduce(1..String.to_integer(rest), path, fn i, path -> [{x - i, y} | path] end)
      end

    get_path(path, rest_moves)
  end

  def get_crosses(path1, path2) do
    MapSet.intersection(
      Enum.into(path1 -- [{0, 0}], MapSet.new()),
      Enum.into(path2 -- [{0, 0}], MapSet.new())
    )
  end

  def path_to_point(path, point) do
    path
    |> Enum.reverse()
    |> Enum.find_index(fn el -> el == point end)
  end

  def process(l1, l2) do
    path1 = get_path([{0, 0}], String.split(l1, ","))
    path2 = get_path([{0, 0}], String.split(l2, ","))

    crosses = get_crosses(path1, path2)

    # # closes crossing distance
    # Enum.map(crosses, fn {x, y} -> abs(x) + abs(y) end)

    # # closes crossing steps
    crosses
    |> Enum.map(fn cross ->
      path_to_point(path1, cross) + path_to_point(path2, cross)
    end)
    |> Enum.min()
  end

  def run do
    [l1, l2] = FileReader.read_lines("lib/day_3/input.txt")
    process(l1, l2)
  end
end
