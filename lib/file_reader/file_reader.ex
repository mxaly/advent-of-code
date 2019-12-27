defmodule FileReader do
  def read_numbers(path) do
    File.read!(path)
    |> String.split(:binary.compile_pattern([",", "\n", " "]))
    |> Enum.filter(fn x -> String.match?(x, ~r/\d+/) end)
    |> Enum.map(&String.to_integer/1)
  end
end
