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

  defp save(memory, [position | _rest], pointer) do
    input = IO.gets("provide the input") |> String.replace("\n", "") |> String.to_integer()
    memory = memory |> replace_at(position, input)
    {memory, pointer + 2}
  end

  def print(memory, [position | _rest], pointer) do
    IO.puts("diagnostics at: #{position}: #{at(memory, position)}")
    {memory, pointer + 2}
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

  def tick({memory}) do
    tick({memory, 0})
  end

  def tick({memory, pointer}) do
    [opp | code] = slice(memory, pointer..-1)

    case(parse_opp(Integer.digits(opp))) do
      {1, config} -> tick(add(memory, code, config, pointer))
      {2, config} -> tick(multiply(memory, code, config, pointer))
      {3, _config} -> tick(save(memory, code, pointer))
      {4, _config} -> tick(print(memory, code, pointer))
      {5, config} -> tick(jump_if_true(memory, code, config, pointer))
      {6, config} -> tick(jump_if_false(memory, code, config, pointer))
      {7, config} -> tick(less_than(memory, code, config, pointer))
      {8, config} -> tick(equals(memory, code, config, pointer))
      {99, _config} -> {:end, memory}
    end
  end

  def restore(input, x, y) do
    input |> replace_at(1, x) |> replace_at(2, y)
  end

  def run(input) do
    {:end, res} = tick({input})
  end
end

# a= [3,225,1,225,6,6,1100,1,238,225,104,0,1101,33,37,225,101,6,218,224,1001,224,-82,224,4,224,102,8,223,223,101,7,224,224,1,223,224,223,1102,87,62,225,1102,75,65,224,1001,224,-4875,224,4,224,1002,223,8,223,1001,224,5,224,1,224,223,223,1102,49,27,225,1101,6,9,225,2,69,118,224,101,-300,224,224,4,224,102,8,223,223,101,6,224,224,1,224,223,223,1101,76,37,224,1001,224,-113,224,4,224,1002,223,8,223,101,5,224,224,1,224,223,223,1101,47,50,225,102,43,165,224,1001,224,-473,224,4,224,102,8,223,223,1001,224,3,224,1,224,223,223,1002,39,86,224,101,-7482,224,224,4,224,102,8,223,223,1001,224,6,224,1,223,224,223,1102,11,82,225,1,213,65,224,1001,224,-102,224,4,224,1002,223,8,223,1001,224,6,224,1,224,223,223,1001,14,83,224,1001,224,-120,224,4,224,1002,223,8,223,101,1,224,224,1,223,224,223,1102,53,39,225,1101,65,76,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,1107,677,226,224,1002,223,2,223,1005,224,329,101,1,223,223,8,677,226,224,102,2,223,223,1006,224,344,1001,223,1,223,108,677,677,224,1002,223,2,223,1006,224,359,1001,223,1,223,1108,226,677,224,102,2,223,223,1006,224,374,1001,223,1,223,1008,677,226,224,102,2,223,223,1005,224,389,101,1,223,223,7,226,677,224,102,2,223,223,1005,224,404,1001,223,1,223,1007,677,677,224,1002,223,2,223,1006,224,419,101,1,223,223,107,677,226,224,102,2,223,223,1006,224,434,101,1,223,223,7,677,677,224,1002,223,2,223,1005,224,449,101,1,223,223,108,677,226,224,1002,223,2,223,1006,224,464,101,1,223,223,1008,226,226,224,1002,223,2,223,1006,224,479,101,1,223,223,107,677,677,224,1002,223,2,223,1006,224,494,1001,223,1,223,1108,677,226,224,102,2,223,223,1005,224,509,101,1,223,223,1007,226,677,224,102,2,223,223,1005,224,524,1001,223,1,223,1008,677,677,224,102,2,223,223,1005,224,539,1001,223,1,223,1107,677,677,224,1002,223,2,223,1006,224,554,1001,223,1,223,1007,226,226,224,1002,223,2,223,1005,224,569,1001,223,1,223,7,677,226,224,1002,223,2,223,1006,224,584,1001,223,1,223,108,226,226,224,102,2,223,223,1005,224,599,1001,223,1,223,8,677,677,224,102,2,223,223,1005,224,614,1001,223,1,223,1107,226,677,224,102,2,223,223,1005,224,629,1001,223,1,223,8,226,677,224,102,2,223,223,1006,224,644,1001,223,1,223,1108,226,226,224,1002,223,2,223,1006,224,659,101,1,223,223,107,226,226,224,1002,223,2,223,1006,224,674,1001,223,1,223,4,223,99,226]

# CPU.run(b)
