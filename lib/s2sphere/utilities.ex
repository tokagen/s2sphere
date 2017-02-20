defmodule S2Sphere.Utilities do
  alias S2Sphere.{
    Point
  }


# def drem(x, y):
#     """Like fmod but rounds to nearest integer instead of floor."""
#     xd = decimal.Decimal(x)
#     yd = decimal.Decimal(y)
#     return float(xd.remainder_near(yd))
#
# def drem(x, y) do
# end

  def xyz_to_face_uv(%Point{} = point) do
    face = Point.largest_abs_component(point)
    face = case {face, point.x < 0, point.y < 0, point.z < 0} do
      {0, true, _, _} -> face + 3
      {1, _, true, _} -> face + 3
      {2, _, _, true} -> face + 3
      {_, _, _, _} -> face
    end

    {u, v} = valid_face_xyz_to_uv(face, point)
    {face, u, v}
  end

  def valid_face_xyz_to_uv(face, %Point{} = point) do
    # Needed?
    # Point.dot_prod(point, Utilities.face_uv_to_xyz(face, 0, 0)) > 0
    case face do
      0 ->
        {(point.y / point.x), (point.z / point.x)}
      1 ->
        {(-point.x / point.y), (point.z / point.y)}
      2 ->
        {(-point.x / point.z), (-point.y / point.z)}
      3 ->
        {(point.z / point.x), (point.y / point.x)}
      4 ->
        {(point.z / point.y), (-point.x / point.y)}
      _->
        {(-point.y / point.z), (-point.x / point.z)}
    end
  end

  def face_uv_to_xyz(face, u, v) do
    case face do
      0 -> %Point{x: 1, y: u, z: v}
      1 -> %Point{x: -u, y: 1, z: v}
      2 -> %Point{x: -u, y: -v, z: 1}
      3 -> %Point{x: -1, y: -v, z: -u}
      4 -> %Point{x: v, y: -1, z: -u}
      _ -> %Point{x: v, y: u, z: -1}
    end
  end
end
