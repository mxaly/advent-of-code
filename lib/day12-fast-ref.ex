defmodule ScannerP2 do
  def vel_for_point(x, y, z, points) do
    points
    |> Enum.reduce({0, 0, 0}, fn collision_point, {xa, ya, za} ->
      {{cx, cy, cz}, _} = collision_point

      {
        cond do
          x < cx -> xa + 1
          x > cx -> xa - 1
          x == cx -> xa
        end,
        cond do
          y < cy -> ya + 1
          y > cy -> ya - 1
          y == cy -> ya
        end,
        cond do
          z < cz -> za + 1
          z > cz -> za - 1
          z == cz -> za
        end
      }
    end)
  end

  def calc_point(point, points) do
    {{x, y, z}, {vx, vy, vz}} = point
    {vpx, vpy, vpz} = vel_for_point(x, y, z, points)

    {
      {
        vx + vpx + x,
        vy + vpy + y,
        vz + vpz + z
      },
      {
        vx + vpx,
        vy + vpy,
        vz + vpz
      }
    }
  end

  def step(points) do
    moved = points |> Enum.map(fn point -> calc_point(point, points) end)

    step(moved, points, 1)
  end

  def step(points, points, itrs) do
    itrs
  end

  def step(points, start_points, i) do
    moved = points |> Enum.map(fn point -> calc_point(point, points) end)
    step(moved, start_points, i + 1)
  end
end

# input = [
#   {{15, -2, -6}, {0, 0, 0}},
#   {{-5, -4, -11}, {0, 0, 0}},
#   {{0, -6, 0}, {0, 0, 0}},
#   {{5, 9, 6}, {0, 0, 0}}
# ]

# i2 = [
#   {{-1, 0, 2}, {0, 0, 0}},
#   {{2, -10, -7}, {0, 0, 0}},
#   {{4, -8, 8}, {0, 0, 0}},
#   {{3, 5, -1}, {0, 0, 0}}
# ]

# Benchmark.measure(fn ->
#   Enum.map(0..100, fn _x -> Scanner.step(i2) end)
# end)
