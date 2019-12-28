defmodule Vacum do
  @moduledoc false
  import Enum
  import Map
  import CPU
  import IEx

  @directions [%{x: 0, y: 1}, %{x: 0, y: -1}, %{x: -1, y: 0}, %{x: 1, y: 0}]

  def sequence(input) do
    sequence({input, 0}, 0, [], [])
  end

  def sequence(program, base, args, output) do
    case tick(program, base, args) do
      {:out, {code, pointer, out}, base, args} ->
        sequence({code, pointer}, base, args, [out | output])

      {:end, _} ->
        output
    end
  end

  def parse_to_map(output) do
    ((List.to_string(output) |> String.split("\n")) -- ["", ""])
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.split("")
      |> Enum.filter(fn s -> s != "" end)
      |> Enum.with_index()
      |> Enum.map(fn {v, x} -> {{x, y}, v} end)
    end)
    |> Map.new()
  end

  def is_intersection?({x, y}, map) do
    @directions
    |> Enum.reduce(true, fn %{x: dx, y: dy}, acc -> acc && map[{x + dx, y + dy}] == "#" end)
  end

  def calc_intersections(map) do
    map
    |> Enum.filter(fn {cord, v} -> v == "#" && is_intersection?(cord, map) end)
    |> Enum.map(fn {{x, y}, _} -> x * y end)
    |> Enum.sum()
  end

  def run do
    input = @code |> Enum.with_index() |> Enum.map(fn {el, i} -> {i, el} end) |> Map.new()
    sequence(input) |> Enum.reverse() |> calc
    # IO.puts(map)
  end

  def calc(map) do
    map |> parse_to_map |> calc_intersections
  end
end
