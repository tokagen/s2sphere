defmodule S2Sphere.Angle do
  defstruct radians: 0

  @spec from_degrees(float) :: %S2Sphere.Angle{}
  def from_degrees(degrees) do
    %S2Sphere.Angle{radians: Math.deg2rad(degrees)}
  end

  @spec from_radians(float) :: %S2Sphere.Angle{}
  def from_radians(radians) do
    %S2Sphere.Angle{radians: radians}
  end

  @spec degrees(%S2Sphere.Angle{}) :: float
  def degrees(%S2Sphere.Angle{radians: radians}) do
    Math.rad2deg(radians)
  end

  def radians(%S2Sphere.Angle{} = angle) do
    angle.radians
  end
end
