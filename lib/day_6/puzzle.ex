defmodule Day6 do
  @moduledoc false
  import IEx

  def prepare_structure(lines) do
    lines
    |> Enum.map(fn x -> String.split(x, ")") end)
    |> Enum.group_by(fn [id, _] -> id end, fn [_, destinations] -> destinations end)
  end

  def mark(structure) do
    mark(structure, "COM", nil, 0)
  end

  def mark(structure, start, from, level) do
    if structure[start] do
      new_structure =
        Enum.reduce(
          structure[start],
          structure,
          fn point, structure ->
            Map.merge(structure, mark(structure, point, start, level + 1))
          end
        )

      %{new_structure | start => {structure[start], from, level}}
    else
      Map.merge(structure, %{start => {[], from, level}})
    end
  end

  def get_path(map, id) do
    get_path(map, id, [])
  end

  def get_path(map, "COM", path) do
    path
  end

  def get_path(map, id, path) do
    {_directions, from, _levels} = map[id]
    get_path(map, from, [id | path])
  end

  def paths_intersection(path1, path2) do
    MapSet.intersection(
      Enum.into(path1, MapSet.new()),
      Enum.into(path2, MapSet.new())
    )
    |> MapSet.to_list()
  end

  def run_p1 do
    FileReader.read_lines("lib/day_6/input.txt")
    |> prepare_structure
    |> mark
    |> Enum.map(fn {_key, {_directions, _from, levels}} -> levels end)
    |> Enum.sum()
  end

  def run_p2 do
    map =
      FileReader.read_lines("lib/day_6/input.txt")
      |> prepare_structure
      |> mark

    p1 = get_path(map, "YOU")
    p2 = get_path(map, "SAN")

    path_length =
      (Enum.uniq(p1 ++ p2) -- paths_intersection(p1, p2))
      |> length

    path_length - 2
  end
end
