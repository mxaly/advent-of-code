defmodule MapPrinter do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  def get_map(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end

defmodule Drone do
  import Enum
  import Map
  import CPU
  import IEx


  @directions [%{arg: 1, x: 0, y: 1}, %{arg: 2, x: 0, y: -1}, %{arg: 3, x: -1, y: 0}, %{arg: 4, x: 1, y: 0}]

  @code [3,1033,1008,1033,1,1032,1005,1032,31,1008,1033,2,1032,1005,1032,58,1008,1033,3,1032,1005,1032,81,1008,1033,4,1032,1005,1032,104,99,102,1,1034,1039,102,1,1036,1041,1001,1035,-1,1040,1008,1038,0,1043,102,-1,1043,1032,1,1037,1032,1042,1105,1,124,101,0,1034,1039,1001,1036,0,1041,1001,1035,1,1040,1008,1038,0,1043,1,1037,1038,1042,1105,1,124,1001,1034,-1,1039,1008,1036,0,1041,101,0,1035,1040,1002,1038,1,1043,102,1,1037,1042,1106,0,124,1001,1034,1,1039,1008,1036,0,1041,1002,1035,1,1040,101,0,1038,1043,1002,1037,1,1042,1006,1039,217,1006,1040,217,1008,1039,40,1032,1005,1032,217,1008,1040,40,1032,1005,1032,217,1008,1039,35,1032,1006,1032,165,1008,1040,1,1032,1006,1032,165,1101,0,2,1044,1105,1,224,2,1041,1043,1032,1006,1032,179,1101,1,0,1044,1106,0,224,1,1041,1043,1032,1006,1032,217,1,1042,1043,1032,1001,1032,-1,1032,1002,1032,39,1032,1,1032,1039,1032,101,-1,1032,1032,101,252,1032,211,1007,0,71,1044,1105,1,224,1102,0,1,1044,1106,0,224,1006,1044,247,101,0,1039,1034,101,0,1040,1035,101,0,1041,1036,101,0,1043,1038,1001,1042,0,1037,4,1044,1105,1,0,63,79,32,16,21,23,90,91,50,57,98,31,96,21,59,30,88,68,89,15,28,86,14,75,41,29,86,4,80,51,46,48,68,93,74,17,76,18,32,36,80,2,77,80,9,98,38,82,65,93,76,29,23,89,97,13,75,35,2,91,73,86,69,90,9,78,84,6,16,98,97,91,66,41,99,56,35,78,15,85,67,77,55,96,59,20,88,24,80,48,85,79,92,23,68,67,99,98,96,57,20,32,90,20,6,79,33,97,21,58,90,41,83,83,7,64,14,8,92,59,83,13,96,95,51,89,41,72,51,82,60,34,81,56,77,10,4,14,61,74,94,87,3,86,52,84,92,35,88,28,78,17,57,72,85,67,56,82,83,54,89,33,4,84,3,66,45,85,16,22,74,94,75,57,68,80,86,94,18,27,53,90,72,38,95,34,20,99,98,40,95,93,55,46,7,29,87,32,56,21,98,30,88,95,77,24,73,95,14,85,2,66,73,30,85,8,69,78,75,93,4,76,56,51,89,99,51,94,14,72,39,85,96,98,37,37,75,79,61,73,96,4,97,41,92,68,58,76,29,29,78,97,44,73,67,75,85,18,1,2,9,99,10,98,19,11,73,67,86,1,94,35,29,16,99,27,35,76,42,60,99,43,28,74,11,74,91,81,11,13,91,97,75,80,68,51,81,81,77,51,72,75,59,85,62,83,91,9,20,83,57,61,31,94,80,26,52,93,86,87,78,39,46,74,86,55,24,87,95,16,82,49,75,11,73,92,64,69,43,82,41,50,24,98,8,3,73,77,19,49,99,29,96,35,86,82,60,65,36,92,89,84,69,58,95,31,67,84,44,78,24,80,46,48,98,39,94,10,78,89,95,28,82,41,97,88,23,83,67,42,97,44,78,83,28,29,66,94,45,61,37,79,55,79,30,95,45,47,76,18,84,81,93,29,90,90,86,13,86,18,47,86,87,70,1,92,98,16,70,21,54,85,54,29,73,76,80,59,84,92,16,81,87,33,96,86,29,18,84,42,60,94,67,59,89,26,42,91,42,75,58,95,81,82,38,49,85,52,43,93,90,41,88,85,12,37,77,78,95,35,87,35,35,55,92,72,26,76,19,96,19,87,66,97,81,85,58,58,74,39,74,43,51,90,48,77,56,78,16,81,57,34,95,72,18,6,75,16,61,89,56,59,76,35,18,98,76,5,75,11,86,93,51,94,6,76,84,26,82,10,29,95,74,20,74,78,5,63,14,96,84,54,55,75,85,24,95,72,54,49,92,78,22,95,97,58,70,87,28,41,88,25,75,7,29,95,67,32,82,80,81,41,63,69,56,10,81,75,8,18,94,56,67,18,83,56,64,93,84,60,73,95,13,72,4,96,97,40,77,35,62,78,77,35,73,56,99,40,64,60,90,82,86,52,89,17,21,87,84,19,92,81,92,84,81,67,73,9,26,87,2,11,76,31,72,61,89,11,78,83,67,1,64,97,82,12,73,99,81,68,58,77,15,14,31,91,76,58,17,83,45,54,77,40,47,82,40,72,73,95,10,96,29,77,21,92,87,11,55,93,87,84,8,89,51,24,87,38,97,92,48,99,8,49,78,42,91,78,50,87,89,46,80,83,25,11,74,22,81,39,99,53,93,61,93,65,83,80,35,2,85,27,33,95,24,99,86,23,89,9,26,75,66,81,29,75,20,89,8,97,17,73,63,82,73,90,32,92,68,82,59,93,48,78,67,98,34,91,32,82,73,74,2,77,16,90,61,75,30,92,0,0,21,21,1,10,1,0,0,0,0,0,0]

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
        if((Map.keys(map) |> length) > 1) do
          printable = print(map)
          IO.puts("\r#{printable}")
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

  def step(program, {base, args}, {x, y}, %{arg: direction, x: dx, y: dy}, map, pid) do
    case tick(program, base, [direction]) do
      {:end, _} ->
        map

      {:out, {memory, pointer, out}, base, args} ->
        new_cords = {x + dx, y + dy}
        {map, sign} = case out do
          0 ->
            send(pid, {:put, new_cords, " "})
            {Map.put(map, new_cords, "W") ,"W"}
          1 ->
            send(pid, {:put, new_cords, "█"})
            {Map.put(map, new_cords, "."), "."}
          2 ->
            send(pid, {:put, new_cords, "o"})
            {Map.put(map, new_cords, "o"), "o"}
        end
        {{memory, pointer}, {base, []}, new_cords, map, sign}
    end
  end

  def sequence(input, pid) do
    start_cords = {0, 0}
    map = %{{0, 0} => "S"}
    sequence({input, 0}, {0, []}, start_cords, get_unexplored(map, start_cords), map, pid)
  end

  def sequence(program, config, current_point, directions, map, pid) do
    Process.sleep(50)
    {x, y} = current_point
    send(pid, {:print})
    routes = directions |> Enum.map(fn direction -> step(program, config, current_point, direction, map, pid) end)
    no_moves = routes |> Enum.filter(fn {_, _, _, _, r} -> r != "." end)

    moves = routes -- no_moves
    stream = Task.async_stream(moves, fn({program, config, point, new_map, _}) ->
      [{point, "."} | sequence(program, config, point, get_unexplored(new_map, point), new_map, pid)]
    end, timeout: 50000000, max_concurrency: 500)

    async = Enum.flat_map(stream, fn {:ok, map} -> map end)
    async ++ (no_moves |> Enum.map(fn {_, _, point, _, r} -> {point, r} end))
  end

  def flat_and_merge(map) when is_tuple(map) do
    [map]
  end

  def flat_and_merge(map) when is_list(map) do
    map |> Enum.flat_map(fn(el) -> flat_and_merge(el) end)
  end

  def surrounded_by_oxygen?({x, y}, map) do
    !!(@directions
    |> Enum.map(fn %{x: dx, y: dy} -> map[{x + dx, y + dy}] end)
    |> Enum.find_value(fn v -> v=="o" end))
  end

  def fill_oxygen(map) do fill_oxygen(map, 1) end
  def fill_oxygen(map, hours) do
    new_map = Map.keys(map)
    |> Enum.reduce(map, fn(cords, m) ->
      if(map[cords] == "." && surrounded_by_oxygen?(cords, map)) do Map.put(m, cords, "o") else m end
    end)
    if(Enum.find_value(new_map, fn {_k, value} -> value == "." end)) do
      fill_oxygen(new_map |> Map.new, hours+1)
    else
      {map |> Map.new, hours}
    end
  end

  def run() do
    {:ok, pid} = start_link
    input = @code |> Enum.with_index() |> Enum.map(fn {el, i} -> {i, el} end) |> Map.new()
    map = sequence(input, pid) |> Map.new
    fill_oxygen(map)
  end

  def print(map) do
    min_x = Map.keys(map) |> Enum.map(fn({x, y}) -> x end) |> Enum.min
    max_x = Map.keys(map) |> Enum.map(fn({x, y}) -> x end) |> Enum.max
    min_y = Map.keys(map) |> Enum.map(fn({x, y}) -> y end) |> Enum.min
    max_y = Map.keys(map) |> Enum.map(fn({x, y}) -> y end) |> Enum.max
    Enum.map(min_y..max_y, fn(y) ->
      Enum.map(min_x..max_x, fn(x) ->  map[{x, y}] || " " end) |> Enum.join()
    end) |> Enum.join("\n")
  end
end
