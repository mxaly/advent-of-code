defmodule Scanner do
  import IEx

  def vel_for_point(point, points, axis) do
    points
    |> Enum.map(fn collision_point ->
      cond do
        point[axis] == collision_point[axis] -> 0
        point[axis] < collision_point[axis] -> 1
        point[axis] > collision_point[axis] -> -1
      end
    end)
    |> Enum.sum
  end

  def add_vel(points, axis) do
    v_axis = String.to_atom("vel_#{axis}")
    points
    |> Enum.map(fn point ->
      vel = vel_for_point(point, points, axis) + (point[v_axis] || 0)
      point
      |> Map.put(v_axis, vel)
      |> Map.put(axis, point[axis] + vel)
    end)
  end

  def step(points, 0) do points end
  def step(points, rem) do
    moved = points
    |> add_vel(:x)
    |> add_vel(:y)
    |> add_vel(:z)

    step(moved, rem-1)
  end

  def point_energy(point) do
    (abs(point[:x]) + abs(point[:y]) + abs(point[:z])) * (abs(point[:vel_x]) + abs(point[:vel_y]) + abs(point[:vel_z]))
  end

  def calc_energy(points) do
    points
    |> Enum.map(&point_energy/1)
    |> Enum.sum
  end

  def energy_after(input, steps) do
    input |> step(steps) |> calc_energy
  end
end


input = [
%{x: 15, y: -2, z: -6},
%{x: -5, y: -4, z: -11},
%{x: 0, y: -6, z: 0},
%{x: 5, y: 9, z: 6}
]

i2 = [
  %{x: -1, y: 0, z: 2},
  %{x: 2, y: -10, z: -7},
  %{x: 4, y: -8, z: 8},
  %{x: 3, y: 5, z: -1}
]

i3 = [
  %{x: -8, y: -10, z: 0},
  %{x: 5, y: 5, z: 10},
  %{x: 2, y: -7, z: 3},
  %{x: 9, y: -8, z: -3}
]

 Scanner.energy_after(input, 1000)
# Scanner.vel_for_point(%{x: -1, y: 0, z: 2}, i2, :x)



