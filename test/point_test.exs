defmodule PointTest do
  use ExUnit.Case
  alias S2Sphere.Point

  test "abs" do
    assert Point.abs(%Point{x: -1, y: -1, z: -1}) == %Point{x: 1, y: 1, z: 1}
    assert Point.abs(%Point{x: -1, y: 1, z: -1}) == %Point{x: 1, y: 1, z: 1}
  end

  test "largest_abs_component" do
    assert Point.largest_abs_component(%Point{x: 3, y: 2, z: 1}) == 0
    assert Point.largest_abs_component(%Point{x: 0, y: 2, z: 1}) == 1
    assert Point.largest_abs_component(%Point{x: 3, y: 2, z: 4}) == 2
    assert Point.largest_abs_component(%Point{x: 0, y: 2, z: 3}) == 2
  end
end
