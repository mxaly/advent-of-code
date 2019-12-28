defmodule FileReader do
  @moduledoc false
  def read_numbers(path) do
    File.read!(path)
    |> String.split(:binary.compile_pattern([",", "\n", " "]))
    |> Enum.filter(fn x -> String.match?(x, ~r/\d+/) end)
    |> Enum.map(&String.to_integer/1)
  end

  def read_lines(path) do
    File.read!(path)
    |> String.split(:binary.compile_pattern(["\n"]))
    |> Enum.filter(fn x -> x != "" end)
  end
end
