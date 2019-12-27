defmodule Day4 do
  defp get_groups(number) do
    number
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.chunk_by(& &1)
  end

  defp groups_valid?(value) do
    get_groups(value) |> Enum.reduce(false, fn g, acc -> acc || length(g) == 2 end)
  end

  defp increasing?(n) do
    !!Enum.reduce_while(
      n |> Integer.digits(),
      0,
      fn x, acc -> if x >= acc, do: {:cont, x}, else: {:halt, false} end
    )
  end

  def check(x) do
    increasing?(x) && groups_valid?(x)
  end

  def run() do
    Enum.count(382_345..843_167, fn x -> check(x) end)
  end
end
