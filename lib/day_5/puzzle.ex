defmodule Day5 do
  @moduledoc false
  import Enum
  import List
  import CPU

  def sequence(cpu) do
    case tick(cpu) do
      {:out, cpu, value} ->
        value

      {:end, cpu} ->
        cpu
    end
  end

  def run do
    memory = code_from_file("lib/day_5/input.txt")
    sequence(%CPU{memory: memory, args: [5]})
  end
end
