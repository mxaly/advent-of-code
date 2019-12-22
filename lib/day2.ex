defmodule Day2 do
  import Enum
  import List
  import IO

  defp tick(array) do
    tick(array, 0)
  end

  defp tick(memory, pointer) do
    case(slice(memory, pointer..-1)) do
      [1, a, b, position | _rest] ->
        tick(memory |> replace_at(position, at(memory, a) + at(memory, b)), pointer + 4)

      [2, a, b, position | _rest] ->
        tick(memory |> replace_at(position, at(memory, a) * at(memory, b)), pointer + 4)

      [99 | _rest] ->
        {:end, memory}
    end
  end

  def restore(input, x, y) do
    input |> replace_at(1, x) |> replace_at(2, y)
  end

  def run(input) do
    {:end, res} = input |> restore(12, 2) |> tick
    puts(join(res, ","))
  end

  def determinate(input, goal) do
    reduce_while(0..99, 0, fn x, _acc ->
      reduce_while(0..99, 0, fn y, _acc ->
        {:end, [head | _rest]} = input |> restore(x, y) |> tick
        if head == goal, do: {:halt, {:halt, {x, y}}}, else: {:cont, {:cont, {x, y}}}
      end)
    end)
  end
end

# a = [
#   1,
#   0,
#   0,
#   3,
#   1,
#   1,
#   2,
#   3,
#   1,
#   3,
#   4,
#   3,
#   1,
#   5,
#   0,
#   3,
#   2,
#   1,
#   13,
#   19,
#   1,
#   9,
#   19,
#   23,
#   2,
#   13,
#   23,
#   27,
#   2,
#   27,
#   13,
#   31,
#   2,
#   31,
#   10,
#   35,
#   1,
#   6,
#   35,
#   39,
#   1,
#   5,
#   39,
#   43,
#   1,
#   10,
#   43,
#   47,
#   1,
#   5,
#   47,
#   51,
#   1,
#   13,
#   51,
#   55,
#   2,
#   55,
#   9,
#   59,
#   1,
#   6,
#   59,
#   63,
#   1,
#   13,
#   63,
#   67,
#   1,
#   6,
#   67,
#   71,
#   1,
#   71,
#   10,
#   75,
#   2,
#   13,
#   75,
#   79,
#   1,
#   5,
#   79,
#   83,
#   2,
#   83,
#   6,
#   87,
#   1,
#   6,
#   87,
#   91,
#   1,
#   91,
#   13,
#   95,
#   1,
#   95,
#   13,
#   99,
#   2,
#   99,
#   13,
#   103,
#   1,
#   103,
#   5,
#   107,
#   2,
#   107,
#   10,
#   111,
#   1,
#   5,
#   111,
#   115,
#   1,
#   2,
#   115,
#   119,
#   1,
#   119,
#   6,
#   0,
#   99,
#   2,
#   0,
#   14,
#   0
# ]

# {x, y} = CPU.determinate(a, 19690720)
# IO.puts(100 * x + y)
