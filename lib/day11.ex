defmodule Day11 do
  @moduledoc false
  import Enum
  import List
  import Map
  import IEx

  defp get_arg(memory, {arg, 2, base}) do
    memory[base + arg] || 0
  end

  defp get_arg(memory, {arg, 0, _base}) do
    memory[arg] || 0
  end

  defp get_arg(memory, {arg, nil, _base}) do
    memory[arg] || 0
  end

  defp get_arg(_, {arg, 1, _base}) do
    arg
  end

  defp get_position({2, arg, base}) do
    base + arg
  end

  defp get_position({_, arg, _}) do
    arg
  end

  defp parse_opp(opp_digits) do
    if length(opp_digits) > 2 do
      [code, _ | config] = Enum.reverse(opp_digits)
      {code, config}
    else
      {String.to_integer(Enum.join(opp_digits)), []}
    end
  end

  defp add(memory, {a, b, position}, config, pointer, base) do
    memory =
      memory
      |> put(
        get_position({at(config, 2), position, base}),
        get_arg(memory, {a, at(config, 0), base}) + get_arg(memory, {b, at(config, 1), base})
      )

    {memory, pointer + 4}
  end

  defp multiply(memory, {a, b, position}, config, pointer, base) do
    memory =
      memory
      |> put(
        get_position({at(config, 2), position, base}),
        get_arg(memory, {a, at(config, 0), base}) * get_arg(memory, {b, at(config, 1), base})
      )

    {memory, pointer + 4}
  end

  defp save(memory, {position}, config, pointer, base, args) do
    [input | rest_args] = args
    memory = memory |> put(get_position({at(config, 0), position, base}), input)
    {memory, pointer + 2, rest_args}
  end

  def print(memory, {position}, config, pointer, base) do
    # IO.puts("diagnostics: #{get_arg(memory, {position, at(config, 0), base})}")
    {memory, pointer + 2, get_arg(memory, {position, at(config, 0), base})}
  end

  def jump_if_true(memory, {read, position}, config, pointer, base) do
    if get_arg(memory, {read, at(config, 0), base}) != 0 do
      {memory, get_arg(memory, {position, at(config, 1), base})}
    else
      {memory, pointer + 3}
    end
  end

  def jump_if_false(memory, {read, position}, config, pointer, base) do
    if get_arg(memory, {read, at(config, 0), base}) == 0 do
      {memory, get_arg(memory, {position, at(config, 1), base})}
      # {memory, position}
    else
      {memory, pointer + 3}
    end
  end

  defp less_than(memory, {a, b, position}, config, pointer, base) do
    memory =
      if get_arg(memory, {a, at(config, 0), base}) < get_arg(memory, {b, at(config, 1), base}) do
        memory |> put(get_position({at(config, 2), position, base}), 1)
      else
        memory |> put(get_position({at(config, 2), position, base}), 0)
      end

    {memory, pointer + 4}
  end

  defp equals(memory, {a, b, position}, config, pointer, base) do
    memory =
      if get_arg(memory, {a, at(config, 0), base}) == get_arg(memory, {b, at(config, 1), base}) do
        memory |> put(get_position({at(config, 2), position, base}), 1)
      else
        memory |> put(get_position({at(config, 2), position, base}), 0)
      end

    {memory, pointer + 4}
  end

  defp increase_base(memory, {arg}, config, base) do
    base + get_arg(memory, {arg, at(config, 0), base})
  end

  # starting from black
  def tick({memory}) do
    tick({memory, 0}, 0, [0])
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def tick({memory, pointer}, base, args) do
    opp = memory[pointer]
    a = memory[pointer + 1]
    b = memory[pointer + 2]
    c = memory[pointer + 3]

    case(parse_opp(Integer.digits(opp))) do
      {1, config} ->
        tick(add(memory, {a, b, c}, config, pointer, base), base, args)

      {2, config} ->
        tick(multiply(memory, {a, b, c}, config, pointer, base), base, args)

      {3, config} ->
        {memory, pointer, args} = save(memory, {a}, config, pointer, base, args)
        tick({memory, pointer}, base, args)

      {4, config} ->
        {:out, print(memory, {a}, config, pointer, base), base, args}

      {5, config} ->
        tick(jump_if_true(memory, {a, b}, config, pointer, base), base, args)

      {6, config} ->
        tick(jump_if_false(memory, {a, b}, config, pointer, base), base, args)

      {7, config} ->
        tick(less_than(memory, {a, b, c}, config, pointer, base), base, args)

      {8, config} ->
        tick(equals(memory, {a, b, c}, config, pointer, base), base, args)

      {9, config} ->
        tick({memory, pointer + 2}, increase_base(memory, {a}, config, base), args)

      {99, _config} ->
        {:end, memory}
    end
  end

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

      {:out, {memory, pointer, out}, base, args} ->
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

  def draw(path) do
    path
    |> Enum.group_by(fn {{_x, y}, _} -> y end)
    |> Enum.map(fn {y, row} -> {y, Enum.sort_by(row, fn {{x, _}, _} -> x end)} end)
    |> Enum.sort_by(fn {k, _v} -> -k end)
    |> Enum.map(fn {_k, row} -> fill_row(row) |> Enum.join(",") end)
    |> Enum.join("\n")
  end

  def run(input) do
    input = input |> Enum.with_index() |> Enum.map(fn {el, i} -> {i, el} end) |> Map.new()
    sequence(input)
  end
end

# code = [3,8,1005,8,290,1106,0,11,0,0,0,104,1,104,0,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,1,8,10,4,10,1002,8,1,28,1006,0,59,3,8,1002,8,-1,10,101,1,10,10,4,10,108,0,8,10,4,10,101,0,8,53,3,8,1002,8,-1,10,101,1,10,10,4,10,1008,8,0,10,4,10,101,0,8,76,1006,0,81,1,1005,2,10,3,8,102,-1,8,10,1001,10,1,10,4,10,1008,8,1,10,4,10,1002,8,1,105,3,8,102,-1,8,10,1001,10,1,10,4,10,108,1,8,10,4,10,1001,8,0,126,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,1,8,10,4,10,1002,8,1,148,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,1,10,4,10,1001,8,0,171,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,0,10,4,10,101,0,8,193,1,1008,8,10,1,106,3,10,1006,0,18,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,0,8,10,4,10,1001,8,0,225,1,1009,9,10,1006,0,92,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,0,8,10,4,10,1001,8,0,254,2,1001,8,10,1,106,11,10,2,102,13,10,1006,0,78,101,1,9,9,1007,9,987,10,1005,10,15,99,109,612,104,0,104,1,21102,1,825594852136,1,21101,0,307,0,1106,0,411,21101,0,825326580628,1,21101,0,318,0,1105,1,411,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,21102,179557207043,1,1,21101,0,365,0,1106,0,411,21101,0,46213012483,1,21102,376,1,0,1106,0,411,3,10,104,0,104,0,3,10,104,0,104,0,21101,988648727316,0,1,21102,399,1,0,1105,1,411,21102,988224959252,1,1,21101,0,410,0,1106,0,411,99,109,2,21201,-1,0,1,21101,0,40,2,21102,1,442,3,21101,432,0,0,1105,1,475,109,-2,2105,1,0,0,1,0,0,1,109,2,3,10,204,-1,1001,437,438,453,4,0,1001,437,1,437,108,4,437,10,1006,10,469,1102,0,1,437,109,-2,2105,1,0,0,109,4,2102,1,-1,474,1207,-3,0,10,1006,10,492,21101,0,0,-3,21202,-3,1,1,22102,1,-2,2,21101,0,1,3,21102,511,1,0,1105,1,516,109,-4,2105,1,0,109,5,1207,-3,1,10,1006,10,539,2207,-4,-2,10,1006,10,539,21201,-4,0,-4,1106,0,607,21202,-4,1,1,21201,-3,-1,2,21202,-2,2,3,21101,558,0,0,1106,0,516,22101,0,1,-4,21101,1,0,-1,2207,-4,-2,10,1006,10,577,21102,1,0,-1,22202,-2,-1,-2,2107,0,-3,10,1006,10,599,21201,-1,0,1,21101,0,599,0,105,1,474,21202,-2,-1,-2,22201,-4,-2,-4,109,-5,2106,0,0]
# path = CPU11.run(code)

# print = CPU11.draw(path) # > Enum.group_by(fn({{x, y}, _}) -> y end) |> Enum.map(fn({y, row}) -> {y, Enum.sort_by(row, fn({{x,_},_}) -> x end)} end) |> Enum.sort_by(fn {k, _v} -> -k end) |> Enum.map(fn {k, rows} -> Enum.map(rows, fn{{_,_}, c} -> c end) |> Enum.join(",") end) |> Enum.join("\n")
# IO.puts(print)

# pp = path |> Enum.group_by(fn({{x, y}, _}) -> y end) |> Enum.map(fn({y, row}) -> {y, Enum.sort_by(row, fn({{x,_},_}) -> x end)} end) |> Enum.sort_by(fn {k, _v} -> -k end)
