defmodule SpareBank do
  @moduledoc false

  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end)
  end

  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  def state(bucket) do
    Agent.get(bucket, & &1)
  end
end

defmodule Day14 do
  @moduledoc false

  def parse_line(line) do
    [input, output] = String.split(line, "=>")
    [quantity, output] = String.split(output, " ") |> Enum.filter(&(&1 != ""))
    quantity = String.to_integer(quantity)

    recipe =
      String.split(input, ",")
      |> Enum.map(fn el -> String.split(el, " ") |> Enum.filter(&(&1 != "")) end)
      |> Enum.map(fn [q, i] -> {String.to_integer(q), i} end)

    {output, {quantity, recipe}}
  end

  def prepare_cookbook do
    FileReader.read_lines("lib/day_14/input.txt")
    |> Enum.map(&parse_line/1)
    |> Map.new()
    |> Map.put("ORE", {1, []})
  end

  def ore_for(book, chemical, quantity, bank_pid) do
    {producing, recipe} = book[chemical]
    spare = SpareBank.get(bank_pid, chemical) || 0

    {needed, left_in_bank} =
      if spare > quantity do
        {0, spare - quantity}
      else
        {quantity - spare, 0}
      end

    reactions = ceil(needed / producing)
    SpareBank.put(bank_pid, chemical, reactions * producing - needed + left_in_bank)

    recipe
    |> Enum.map(fn {q, chemical} ->
      if chemical == "ORE" do
        reactions * q
      else
        ore_for(book, chemical, q * reactions, bank_pid)
      end
    end)
    |> Enum.sum()
  end

  def step(_book, _bank_pid, left_ore, fuel, _unit) when left_ore < 0 do
    fuel - 1
  end

  def step(book, bank_pid, left_ore, fuel, unit) do
    steps = if floor(left_ore / unit) > 0, do: floor(left_ore / unit), else: 1
    step(book, bank_pid, left_ore - ore_for(book, "FUEL", steps, bank_pid), fuel + steps, unit)
  end

  def run_p1 do
    {:ok, pid} = SpareBank.start_link()
    prepare_cookbook() |> ore_for("FUEL", 1, pid)
    # {sum, pid}
  end

  def run_p2 do
    unit = run_p1()
    {:ok, pid} = SpareBank.start_link()
    prepare_cookbook() |> step(pid, 1_000_000_000_000, 0, unit)
  end
end
