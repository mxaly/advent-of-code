defmodule Day13 do
  @moduledoc false
  import CPU

  def sequence(input, screen_pid) do
    sequence(%CPU{memory: input}, :get_x, %{}, %{}, screen_pid)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def sequence(cpu, action, screen, payload, screen_pid) do
    case tick(cpu) do
      {:end, _} ->
        {screen, payload}

      {:get_arg, cpu} ->
        {{ball_x, _}, _} = screen |> Enum.filter(fn {_, v} -> v == 4 end) |> List.first()
        {{paddle_x, _}, _} = screen |> Enum.filter(fn {_, v} -> v == 3 end) |> List.first()

        args =
          cond do
            ball_x > paddle_x -> [1]
            ball_x < paddle_x -> [-1]
            ball_x == paddle_x -> [0]
          end

        sequence(%CPU{cpu | args: args}, action, screen, payload, screen_pid)

      {:out, cpu, out} ->
        case action do
          :get_x ->
            sequence(cpu, :get_y, screen, Map.put(payload, :x, out), screen_pid)

          :get_y ->
            sequence(
              cpu,
              :get_sign,
              screen,
              Map.put(payload, :y, out),
              screen_pid
            )

          # credo:disable-for-lines:20 Elixir.Credo.Check.Refactor.Nesting
          :get_sign ->
            case payload do
              %{x: -1, y: 0} ->
                sequence(
                  cpu,
                  :get_x,
                  screen,
                  Map.put(payload, :score, out),
                  screen_pid
                )

              _ ->
                %{x: x, y: y} = payload
                screen = Map.put(screen, {x, y}, out)
                # send(screen_pid, {:put_pixel, {x, y}, get_char(out)})
                # send(screen_pid, {:print})
                sequence(cpu, :get_x, screen, payload, screen_pid)
            end
        end
    end
  end

  def get_char(value) do
    case value do
      0 -> " "
      1 -> "W"
      2 -> "█"
      3 -> "—"
      4 -> "•"
    end
  end

  def calc_blocks(screen) do
    screen |> Enum.filter(fn %{value: value} -> value == 2 end) |> Enum.count()
  end

  def run do
    {:ok, pid} = Screen.start_link()

    {_, %{score: score}} =
      CPU.code_from_file("lib/day_13/input.txt")
      |> sequence(pid)

    score
  end
end
