defmodule MapPrinter do
  @moduledoc false
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  def get_map(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end

defmodule Drone do
  @moduledoc false
  import Enum
  import Map
  import CPU
  import IEx

  @directions [
    %{arg: 1, x: 0, y: 1},
    %{arg: 2, x: 0, y: -1},
    %{arg: 3, x: -1, y: 0},
    %{arg: 4, x: 1, y: 0}
  ]

  # def get_unexplored(screen, {x, y}) do get_unexplored(screen, {x, y}, []) end

  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get_map, caller} ->
        # send(caller, map)
        loop(map)

      {:put, key, value} ->
        loop(Map.put(map, key, value))

      {:print} ->
        if Map.keys(map) |> length > 1 do
          printable = print(map)
          # IO.puts("\r\n\n\n\n\n\n#{printable}")
        end

        loop(map)
    end
  end

  def get_unexplored(map, {x, y}) do
    @directions
    |> Enum.map(fn %{arg: d, x: dx, y: dy} ->
      {%{arg: d, x: dx, y: dy}, map[{x + dx, y + dy}]}
    end)
    |> Enum.filter(fn {_, value} -> value == nil end)
    |> Enum.map(fn {d, _v} -> d end)
  end

  # def step(program, {base, args}, {x, y}, %{arg: direction, x: dx, y: dy}, map, pid) do
  def step(cpu, {x, y}, %{arg: direction, x: dx, y: dy}, map, pid) do
    case tick(%CPU{cpu | args: [direction]}) do
      {:end, _} ->
        map

      {:out, cpu, value} ->
        new_cords = {x + dx, y + dy}

        {map, sign} =
          case value do
            0 ->
              send(pid, {:put, new_cords, "+"})
              {Map.put(map, new_cords, "W"), "W"}

            1 ->
              send(pid, {:put, new_cords, "█"})
              {Map.put(map, new_cords, "."), "."}

            2 ->
              send(pid, {:put, new_cords, "o"})
              {Map.put(map, new_cords, "o"), "o"}
          end

        {cpu, new_cords, map, sign}
    end
  end

  def sequence(input, pid) do
    start_cords = {0, 0}
    map = %{{0, 0} => "S"}
    sequence(%CPU{memory: input}, start_cords, get_unexplored(map, start_cords), map, pid)
  end

  def sequence(cpu, current_point, directions, map, pid) do
    # Process.sleep(50)

    {x, y} = current_point
    send(pid, {:print})

    directions
    |> Task.async_stream(fn direction ->
      step(cpu, current_point, direction, map, pid)
    end)
    |> Enum.map(fn {:ok, route} -> route end)
    |> Task.async_stream(
      fn {cpu, point, new_map, sign} ->
        if sign == "." do
          [
            {point, "."}
            | sequence(cpu, point, get_unexplored(new_map, point), new_map, pid)
          ]
        else
          [{point, sign}]
        end
      end,
      timeout: 50_000_000,
      max_concurrency: 500
    )
    |> Enum.flat_map(fn {:ok, map} -> map end)
  end

  def flat_and_merge(map) when is_tuple(map) do
    [map]
  end

  def flat_and_merge(map) when is_list(map) do
    map |> Enum.flat_map(fn el -> flat_and_merge(el) end)
  end

  def surrounded_by_oxygen?({x, y}, map) do
    !!(@directions
       |> Enum.map(fn %{x: dx, y: dy} -> map[{x + dx, y + dy}] end)
       |> Enum.find_value(fn v -> v == "o" end))
  end

  def fill_oxygen(map, pid) do
    fill_oxygen(map, pid, 1)
  end

  def fill_oxygen(map, pid, hours) do
    send(pid, {:print})
    # Process.sleep(50)

    new_map =
      Map.keys(map)
      |> Enum.reduce(map, fn cords, m ->
        if map[cords] == "." && surrounded_by_oxygen?(cords, map) do
          send(pid, {:put, cords, "░"})
          Map.put(m, cords, "o")
        else
          m
        end
      end)

    if Enum.find_value(new_map, fn {_k, value} -> value == "." end) do
      fill_oxygen(new_map |> Map.new(), pid, hours + 1)
    else
      send(pid, {:print})
      {map |> Map.new(), hours}
    end
  end

  def run() do
    {:ok, pid} = start_link

    CPU.code_from_file("files/day15.txt")
    |> sequence(pid)
    |> Map.new()
    |> fill_oxygen(pid)
  end

  def print(map) do
    min_x = Map.keys(map) |> Enum.map(fn {x, y} -> x end) |> Enum.min()
    max_x = Map.keys(map) |> Enum.map(fn {x, y} -> x end) |> Enum.max()
    min_y = Map.keys(map) |> Enum.map(fn {x, y} -> y end) |> Enum.min()
    max_y = Map.keys(map) |> Enum.map(fn {x, y} -> y end) |> Enum.max()

    Enum.map(min_y..(min_y + 40), fn y ->
      Enum.map((min_x - 10)..max_x, fn x -> map[{x, y}] || " " end) |> Enum.join()
    end)
    |> Enum.join("\n")
  end
end
