defmodule S2Sphere.Point do
  alias S2Sphere.Point
  defstruct x: nil, y: nil, z: nil

  def abs(%Point{x: x, y: y, z: z}) do
    %Point{x: Kernel.abs(x), y: Kernel.abs(y), z: Kernel.abs(z)}
  end

  def largest_abs_component(%Point{} = point) do
    %Point{x: x, y: y, z: z} = Point.abs(point)
    cond do
      ((x > y) && (x > z)) -> 0
      ((x > y) && (x <= z)) -> 2
      ((x <= y) && (y > z)) -> 1
      true -> 2
    end
  end

  def angle(%Point{} = p1, %Point{} = p2) do
    a = p1
    |> Point.cross_prod(p2)
    |> norm

    b = p1
    |> Point.dot_prod(p2)

    :math.atan2(a, b)
  end

  def cross_prod(%Point{x: x1, y: y1, z: z1} = p1, %Point{x: x2, y: y2, z: z2} = p2) do
    %Point{x: y1 * z2 - z1 * y2, y: z1 * x2 - x1 * z2, z: x1 * y2 - y1 * x2}
  end

  def dot_prod(%Point{x: x1, y: y1, z: z1} = p1, %Point{x: x2, y: y2, z: z2} = p2) do
    x1 * x2 + y1 * y2 + z1 * z2
  end

  def norm(%Point{} = point) do
    :math.sqrt(Point.norm2(point))
  end

  def norm2(%Point{x: x, y: y, z: z}) do
    :math.pow(x, 2) + :math.pow(y, 2) + :math.pow(z, 2)
  end

  def normalize(%Point{x: x, y: y, z: z} = point) do
    n = Point.norm(point)
    n = case n != 0 do
      true -> 1.0 / n
      false -> n
    end

    %Point{x: x * n, y: y * n, z: z * n}
  end
end
