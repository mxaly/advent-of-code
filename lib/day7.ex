defmodule CPU do
  import Enum
  import List

  defp get_arg(memory, {arg, 0}) do
    at(memory, arg)
  end

  defp get_arg(memory, {arg, nil}) do
    at(memory, arg)
  end

  defp get_arg(_, {arg, 1}) do
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

  defp add(memory, [a, b, position | _rest], config, pointer) do
    memory =
      memory
      |> replace_at(
        position,
        get_arg(memory, {a, at(config, 0)}) + get_arg(memory, {b, at(config, 1)})
      )

    {memory, pointer + 4}
  end

  defp multiply(memory, [a, b, position | _rest], config, pointer) do
    memory =
      memory
      |> replace_at(
        position,
        get_arg(memory, {a, at(config, 0)}) * get_arg(memory, {b, at(config, 1)})
      )

    {memory, pointer + 4}
  end

  defp save(memory, [position | _rest], pointer, arg) do
    # input = IO.gets("provide the input") |> String.replace("\n", "") |> String.to_integer()
    memory = memory |> replace_at(position, arg)
    {memory, pointer + 2}
  end

  def print(memory, [position | _rest], pointer) do
    IO.puts("diagnostics at: #{position}: #{at(memory, position)}")
    # {memory, pointer + 2}
    at(memory, position)
  end

  # def jump_if_true(memory, [0, _ | rest], _, pointer) do {memory, pointer + 2} end
  def jump_if_true(memory, [read, position | _rest], config, pointer) do
    if get_arg(memory, {read, at(config, 0)}) != 0 do
      {memory, get_arg(memory, {position, at(config, 1)})}
    else
      {memory, pointer + 3}
    end
  end

  def jump_if_false(memory, [read, position | _rest], config, pointer) do
    if get_arg(memory, {read, at(config, 0)}) == 0 do
      {memory, get_arg(memory, {position, at(config, 1)})}
      # {memory, position}
    else
      {memory, pointer + 3}
    end
  end

  defp less_than(memory, [a, b, position | _rest], config, pointer) do
    memory =
      if(get_arg(memory, {a, at(config, 0)}) < get_arg(memory, {b, at(config, 1)})) do
        memory |> replace_at(position, 1)
      else
        memory |> replace_at(position, 0)
      end

    {memory, pointer + 4}
  end

  defp equals(memory, [a, b, position | _rest], config, pointer) do
    memory =
      if(get_arg(memory, {a, at(config, 0)}) == get_arg(memory, {b, at(config, 1)})) do
        memory |> replace_at(position, 1)
      else
        memory |> replace_at(position, 0)
      end

    {memory, pointer + 4}
  end

  def tick({memory}, ext_args) do
    tick({memory, 0}, ext_args)
  end

  def tick({memory, pointer}, ext_args) do
    [opp | code] = slice(memory, pointer..-1)

    case(parse_opp(Integer.digits(opp))) do
      {1, config} ->
        tick(add(memory, code, config, pointer), ext_args)

      {2, config} ->
        tick(multiply(memory, code, config, pointer), ext_args)

      {3, _config} ->
        [arg | rest] = ext_args
        tick(save(memory, code, pointer, arg), rest)

      {4, _config} ->
        print(memory, code, pointer)

      {5, config} ->
        tick(jump_if_true(memory, code, config, pointer), ext_args)

      {6, config} ->
        tick(jump_if_false(memory, code, config, pointer), ext_args)

      {7, config} ->
        tick(less_than(memory, code, config, pointer), ext_args)

      {8, config} ->
        tick(equals(memory, code, config, pointer), ext_args)

      {99, _config} ->
        {:end, memory}
    end
  end

  def restore(input, x, y) do
    input |> replace_at(1, x) |> replace_at(2, y)
  end

  def run(input, args) do
    tick({input}, args)
  end

  def run_sequence(code, sequence) do
    Enum.reduce(sequence, 0, fn seq, acc ->
      run(code, [seq, acc])
    end)
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def find_best(input) do
  end
end

# a=[3,8,1001,8,10,8,105,1,0,0,21,42,51,76,101,118,199,280,361,442,99999,3,9,101,5,9,9,102,2,9,9,1001,9,4,9,102,2,9,9,4,9,99,3,9,1002,9,3,9,4,9,99,3,9,1002,9,4,9,1001,9,3,9,1002,9,5,9,101,3,9,9,1002,9,2,9,4,9,99,3,9,101,4,9,9,1002,9,2,9,1001,9,3,9,1002,9,3,9,101,4,9,9,4,9,99,3,9,101,3,9,9,1002,9,3,9,101,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,99]

# CPU.run_sequence(c, [1,0,4,3,2])
