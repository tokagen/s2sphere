defmodule AngleTest do
  use ExUnit.Case
  alias S2Sphere.Angle

  test "default radians is 0" do
    assert %Angle{}.radians == 0
  end

  test "test values" do
    assert Angle.from_radians(Math.pi).radians == Math.pi
    assert Angle.degrees(Angle.from_radians(Math.pi)) == 180.0
    assert Angle.from_degrees(180).radians == Math.pi
    assert Angle.degrees(Angle.from_degrees(180)) == 180

    assert Angle.degrees(Angle.from_radians((-Math.pi) / 2)) == -90
    assert Angle.from_degrees(-45).radians == -Math.pi / 4
  end
end
