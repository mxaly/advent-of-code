defmodule Day2 do
  @moduledoc false

  import Enum
  import Map
  import CPU

  def restore(memory, x, y) do
    memory |> put(1, x) |> put(2, y)
  end

  def run(memory) do
    {:end, %{0 => head}} = tick(%CPU{memory: memory |> restore(12, 2)})
    head
  end

  # credo:disable-for-lines:8 Elixir.Credo.Check.Refactor.Nesting
  def determinate(input, goal) do
    reduce_while(0..99, 0, fn x, _acc ->
      reduce_while(0..99, 0, fn y, _acc ->
        {:end, %{0 => head}} = tick(%CPU{memory: input |> restore(x, y)})
        if head == goal, do: {:halt, {:halt, {x, y}}}, else: {:cont, {:cont, {x, y}}}
      end)
    end)
  end

  def run_p1 do
    memory = CPU.code_from_file("lib/day_2/input.txt") |> restore(12, 2)
    {:end, %{0 => head}} = tick(%CPU{memory: memory})
    head
  end

  def run_p2 do
    {x, y} =
      CPU.code_from_file("lib/day_2/input.txt")
      |> determinate(19_690_720)

    100 * x + y
  end
end
