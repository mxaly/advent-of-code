defmodule Screen do
  @moduledoc false
  use Agent

  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(pixels) do
    receive do
      {:get_pixels, caller} ->
        # send(caller, map)
        loop(pixels)

      {:put_pixel, key, value} ->
        loop(Map.put(pixels, key, value))

      {:print} ->
        if Map.keys(pixels) |> length > 1, do: print(pixels)
        loop(pixels)
    end
  end

  def get_ranges(pixels, flip) do
    min_x = Map.keys(pixels) |> Enum.map(fn {x, _y} -> x end) |> Enum.min()
    max_x = Map.keys(pixels) |> Enum.map(fn {x, _y} -> x end) |> Enum.max()
    min_y = Map.keys(pixels) |> Enum.map(fn {_x, y} -> y end) |> Enum.min()
    max_y = Map.keys(pixels) |> Enum.map(fn {_x, y} -> y end) |> Enum.max()

    case flip do
      :flip_x -> {max_x..min_x, min_y..max_y}
      :flip_y -> {min_x..max_x, max_y..min_y}
      {:flip_x, :flip_y} -> {max_x..min_x, max_y..min_y}
      _ -> {min_x..max_x, min_y..max_y}
    end
  end

  def draw(pixels), do: draw(pixels, nil)

  def draw(pixels, flip) do
    {x_range, y_range} = get_ranges(pixels, flip)

    Enum.map(y_range, fn y ->
      Enum.map(x_range, fn x -> pixels[{x, y}] || " " end) |> Enum.join()
    end)
    |> Enum.join("\n")
  end

  def print(pixels) do
    print(pixels, nil)
  end

  def print(pixels, flip) do
    IO.write("\r#{draw(pixels, flip)}")
  end
end
