input = [
  "COM)B",
  "B)C",
  "C)D",
  "D)E",
  "E)F",
  "B)G",
  "G)H",
  "D)I",
  "E)J",
  "J)K",
  "K)L"
]

defmodule Day6 do
  def prepare_structure(lines) do
    lines
    |> Enum.map(fn x -> String.split(x, ")") end)
    |> Enum.group_by(fn [id, _] -> id end, fn [_, destinations] -> destinations end)
  end

  def mark(structure) do
    mark(structure, "COM", 0)
  end

  def mark(structure, start, level) do
    if structure[start] do
      new_structure =
        Enum.reduce(
          structure[start],
          structure,
          fn point, structure -> Map.merge(structure, mark(structure, point, level + 1)) end
        )

      %{new_structure | start => {structure[start], level}}
    else
      Map.merge(structure, %{start => {[], level}})
    end
  end

  def run(path) do
    File.read!(path)
    |> String.split("\n")
    |> prepare_structure
    |> mark
    |> Enum.map(fn {_key, {_directions, levels}} -> levels end)
    |> Enum.sum()
  end
end

# Test.run(input)
