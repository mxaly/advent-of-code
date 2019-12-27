defmodule Day7 do
  import CPU

  def loop(sequence, cpus, input) do
    [seq | rest_sequence] = sequence

    case tick(%CPU{cpus[seq] | args: cpus[seq].args ++ [input]}) do
      {:out, cpu, value} ->
        Map.put(cpus, seq, cpu)
        loop(rest_sequence ++ [seq], Map.put(cpus, seq, %CPU{cpu | args: []}), value)

      {:end, _cpu} ->
        input
    end
  end

  def run_sequence_loop(code, sequence) do
    cpus = sequence |> Enum.map(fn seq -> {seq, %CPU{memory: code, args: [seq]}} end) |> Map.new()
    loop(sequence, cpus, 0)
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def run(options) do
    memory = CPU.code_from_file("lib/day_7/input.txt")

    stream =
      Task.async_stream(permutations(options), fn sequence ->
        run_sequence_loop(memory, sequence)
      end)

    Enum.map(stream, fn {:ok, result} -> result end)
    |> Enum.max()
  end

  def run_p1 do
    run([0, 1, 2, 3, 4])
  end

  def run_p2 do
    run([5, 6, 7, 8, 9])
  end
end
