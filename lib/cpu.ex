defmodule CPU do
  import Enum
  import Map

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
    if(length(opp_digits) > 2) do
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
    case args do
      [] ->
        {:halt, {memory, pointer}}

      _ ->
        [input | rest_args] = args
        memory = memory |> put(get_position({at(config, 0), position, base}), input)
        {memory, pointer + 2, rest_args}
    end
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
      if(get_arg(memory, {a, at(config, 0), base}) < get_arg(memory, {b, at(config, 1), base})) do
        memory |> put(get_position({at(config, 2), position, base}), 1)
      else
        memory |> put(get_position({at(config, 2), position, base}), 0)
      end

    {memory, pointer + 4}
  end

  defp equals(memory, {a, b, position}, config, pointer, base) do
    memory =
      if(
        get_arg(memory, {a, at(config, 0), base}) == get_arg(memory, {b, at(config, 1), base})
      ) do
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
        case save(memory, {a}, config, pointer, base, args) do
          {:halt, program} -> {:get_arg, program, base, args}
          {memory, pointer, args} -> tick({memory, pointer}, base, args)
        end

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
end
