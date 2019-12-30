defmodule Day16 do
  @moduledoc false
  @base_shift [0, 1, 0, -1]
  @input 59_756_772_370_948_995_765_943_195_844_952_640_015_210_703_313_486_295_362_653_878_290_009_098_923_609_769_261_473_534_009_395_188_480_864_325_959_786_470_084_762_607_666_312_503_091_505_466_258_796_062_230_652_769_633_818_282_653_497_853_018_108_281_567_627_899_722_548_602_257_463_608_530_331_299_936_274_116_326_038_606_007_040_084_159_138_769_832_784_921_878_333_830_514_041_948_066_594_667_152_593_945_159_170_816_779_820_264_758_715_101_494_739_244_533_095_696_039_336_070_510_975_612_190_417_391_067_896_410_262_310_835_830_006_544_632_083_421_447_385_542_256_916_141_256_383_813_360_662_952_845_638_955_872_442_636_455_511_906_111_157_861_890_394_133_454_959_320_174_572_270_568_292_972_621_253_460_895_625_862_616_228_998_147_301_670_850_340_831_993_043_617_316_938_748_361_984_714_845_874_270_986_989_103_792_418_940_945_322_846_146_634_931_990_046_966_552

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
    digits = Integer.digits(@input)
    calc_phases(digits, 100) |> Enum.take(8) |> Enum.join("")
  end
end
