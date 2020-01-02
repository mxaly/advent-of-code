defmodule Day16 do
  @moduledoc false
  @base_shift [0, 1, 0, -1]
  @input "59756772370948995765943195844952640015210703313486295362653878290009098923609769261473534009395188480864325959786470084762607666312503091505466258796062230652769633818282653497853018108281567627899722548602257463608530331299936274116326038606007040084159138769832784921878333830514041948066594667152593945159170816779820264758715101494739244533095696039336070510975612190417391067896410262310835830006544632083421447385542256916141256383813360662952845638955872442636455511906111157861890394133454959320174572270568292972621253460895625862616228998147301670850340831993043617316938748361984714845874270986989103792418940945322846146634931990046966552"
  def generate_shifts(n) do
    1..n
    |> Enum.map(fn n ->
      Enum.flat_map(@base_shift, fn el -> List.duplicate(el, n) end)
    end)
  end

  def calc_digit(input, [], org_shift, acc) do
    calc_digit(input, org_shift, org_shift, acc)
  end

  def calc_digit([], _shift, _org_shift, acc) do
    acc
  end

  def calc_digit([a | input], [b | shift], org_shift, acc) do
    calc_digit(input, shift, org_shift, acc + a * b)
  end

  def calc_digit(input, shift) do
    calc_digit([0 | input], shift, shift, 0)
    |> abs
    |> Integer.digits()
    |> List.last()
  end

  def calc_phase(shifts, digits) do
    Enum.map(shifts, fn shift -> calc_digit(digits, shift) end)
  end

  def calc_phases(digits, phases) do
    shifts = generate_shifts(length(digits))

    1..phases
    |> Enum.reduce(digits, fn _phase, acc ->
      calc_phase(shifts, acc)
    end)
  end

  def run_p1 do
    digits =
      @input
      |> String.split("")
      |> Enum.filter(fn x -> x != "" end)
      |> Enum.map(&String.to_integer/1)

    calc_phases(digits, 100) |> Enum.take(8) |> Enum.join("")
  end

  def run_p2 do
    digits =
      @input
      |> String.split("")
      |> Enum.filter(fn x -> x != "" end)
      |> Enum.map(&String.to_integer/1)
      |> List.duplicate(10000)
      |> List.flatten()

    offset = digits |> Enum.take(7) |> Enum.join("") |> String.to_integer()
    input = Enum.slice(digits, offset..length(digits)) |> Enum.reverse()

    Enum.reduce(1..100, input, fn _i, input ->
      {res, _sum} =
        Enum.map_reduce(input, 0, fn i, acc ->
          res = rem(acc + i, 10)
          {res, res}
        end)

      res
    end)
    |> Enum.reverse()
    |> Enum.take(8)
    |> Enum.join("")
  end
end
