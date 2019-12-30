defmodule Scanner do
  @moduledoc false

  @input [
    %{x: 15, y: -2, z: -6, vel_x: 0, vel_y: 0, vel_z: 0},
    %{x: -5, y: -4, z: -11, vel_x: 0, vel_y: 0, vel_z: 0},
    %{x: 0, y: -6, z: 0, vel_x: 0, vel_y: 0, vel_z: 0},
    %{x: 5, y: 9, z: 6, vel_x: 0, vel_y: 0, vel_z: 0}
  ]

  def vel_for_point(point, points, axis) do
    points
    |> Enum.map(fn collision_point ->
      cond do
        point[axis] == collision_point[axis] -> 0
        point[axis] < collision_point[axis] -> 1
        point[axis] > collision_point[axis] -> -1
      end
    end)
    |> Enum.sum()
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

  def step(points, 0) do
    points
  end

  def step(points, steps) do
    moved =
      points
      |> add_vel(:x)
      |> add_vel(:y)
      |> add_vel(:z)

    step(moved, steps - 1)
  end

  def axis_step(points, axis) do
    axis_step(add_vel(points, axis), points, axis, 1)
  end

  def axis_step(points, points, _axis, it) do
    it
  end

  def axis_step(points, start_points, axis, it) do
    axis_step(add_vel(points, axis), start_points, axis, it + 1)
  end

  def find_cycle_length(input) do
    sx = axis_step(input, :x)
    sy = axis_step(input, :y)
    sz = axis_step(input, :z)
    sx |> RC.lcm(sy) |> RC.lcm(sz)
  end

  def point_energy(point) do
    (abs(point[:x]) + abs(point[:y]) + abs(point[:z])) *
      (abs(point[:vel_x]) + abs(point[:vel_y]) + abs(point[:vel_z]))
  end

  def calc_energy(points) do
    points
    |> Enum.map(&point_energy/1)
    |> Enum.sum()
  end

  def energy_after(input, steps) do
    input |> step(steps) |> calc_energy
  end

  def run_p1 do
    energy_after(@input, 1000)
  end

  def run_p2 do
    find_cycle_length(@input)
  end
end
