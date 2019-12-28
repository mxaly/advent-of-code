defmodule Day11 do
  @moduledoc false
  import Enum
  import List
  import Map
  import CPU

  def get_paint(path, point) do
    path[point] || 0
  end

  def rotate(:up, direction) do
    case direction do
      0 -> :left
      1 -> :right
    end
  end

  def rotate(:left, direction) do
    case direction do
      0 -> :down
      1 -> :up
    end
  end

  def rotate(:down, direction) do
    case direction do
      0 -> :right
      1 -> :left
    end
  end

  def rotate(:right, direction) do
    case direction do
      0 -> :up
      1 -> :down
    end
  end

  def move({x, y}, direction) do
    case direction do
      :up -> {x, y + 1}
      :down -> {x, y - 1}
      :left -> {x - 1, y}
      :right -> {x + 1, y}
    end
  end

  def sequence(input) do
    sequence({input, 0}, {0, [1]}, :up, :paint, %{}, {0, 0})
  end

  def sequence(program, {base, args}, direction, action, path, current_cord) do
    case tick(program, base, args) do
      {:end, _} ->
        path

      {:out, %CPU{memory: memory, pointer: pointer, base: base, args: args}, out} ->
        case action do
          :paint ->
            sequence(
              {memory, pointer},
              {base, args},
              direction,
              :move,
              Map.put(path, current_cord, out),
              current_cord
            )

          :move ->
            direction = rotate(direction, out)
            cord = move(current_cord, direction)

            sequence(
              {memory, pointer},
              {base, [get_paint(path, cord)]},
              direction,
              :paint,
              path,
              cord
            )
        end
    end
  end

  def fill_row(row) do
    [{{x, _}, _} | _rest] = row

    extra =
      if x > 0 do
        Enum.map(0..(x - 1), fn _ -> {{0, 0}, 0} end)
      else
        []
      end

    Enum.map(extra ++ row, fn {{_, _}, c} -> c end)
  end

  def get_char(1), do: "█"

  def get_char(0), do: " "

  def run do
    out =
      CPU.code_from_file("lib/day_11/input.txt")
      |> sequence
      |> Enum.map(fn {key, value} -> {key, get_char(value)} end)
      |> Map.new()

    Screen.draw(out, :flip_y)
  end
end
