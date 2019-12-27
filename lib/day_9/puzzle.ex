defmodule Day9 do
  import CPU
  import IEx

  def loop(cpu) do
    case tick(cpu) do
      {:out, _cpu, value} ->
        value

      {:end, cpu} ->
        cpu
    end
  end

  def run do
    input = CPU.code_from_file("lib/day_9/input.txt")
    loop(%CPU{memory: input, args: [2]})
  end
end
