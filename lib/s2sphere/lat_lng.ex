defmodule S2Sphere.LatLng do
  alias S2Sphere.LatLng
  defstruct lat: nil, lng: nil

  def from_degrees({lat, lng}) do
    %LatLng{lat: Math.deg2rad(lat), lng: Math.deg2rad(lng)}
  end

  def from_radians({lat, lng}) do
    %LatLng{lat: lat, lng: lng}
  end

  def to_degrees(%LatLng{lat: lat, lng: lng} = point) do
    {
      lat |> S2Sphere.Angle.from_radians |> S2Sphere.Angle.degrees,
      lng |> S2Sphere.Angle.from_radians |> S2Sphere.Angle.degrees
    }
  end

  def from_point(%S2Sphere.Point{} = point) do
    with lat <- point |> LatLng.latitude,
         lng <- point |> LatLng.longitude
    do
      %LatLng{lat: lat.radians, lng: lng.radians}
    end
  end

  def from_angles(%S2Sphere.Angle{radians: lat_rads}, %S2Sphere.Angle{radians: lng_rads}) do
    %LatLng{lat: lat_rads, lng: lng_rads}
  end

  def default() do
    %LatLng{lat: 0, lng: 0}
  end

  def invalid do
    %LatLng{lat: Math.pi, lng: 2 * Math.pi}
  end

  def latitude(%S2Sphere.Point{x: x, y: y, z: z} = point) do
    S2Sphere.Angle.from_radians(:math.atan2(z, :math.sqrt(x * x + y * y)))
  end

  def longitude(%S2Sphere.Point{x: x, y: y}) do
    S2Sphere.Angle.from_radians(:math.atan2(y, x))
  end

  def lat(%LatLng{lat: lat}) do
    S2Sphere.Angle.from_radians(lat)
  end

  def lng(%LatLng{lng: lng}) do
    S2Sphere.Angle.from_radians(lng)
  end

  def is_valid(%LatLng{lat: lat, lng: lng} = latlng) do
    (abs(LatLng.lat(latlng).radians) <= (Math.pi / 2) and abs(LatLng.lng(latlng).radians) <= Math.pi)
  end

  def to_point(%LatLng{lat: lat, lng: lng} = latlng) do
    phi = latlng
    |> LatLng.lat
    phi = phi.radians

    theta = latlng
    |> LatLng.lng
    theta = theta.radians

    cosphi = :math.cos(phi)

    %S2Sphere.Point{
      x: :math.cos(theta) * cosphi,
      y: :math.sin(theta) * cosphi,
      z: :math.sin(phi)
    }
  end

  def normalized(%LatLng{} = latlng) do
    lat_rads = latlng
    |> LatLng.lat
    lat_rads = lat_rads.radians

    lng_rads = latlng
    |> LatLng.lng
    lng_rads = lng_rads.radians
    %LatLng{
      lat: max(-Math.pi / 2.0, min(Math.pi / 2.0, lat_rads)),
      lng: max(lng_rads, 2 * Math.pi)
    }
  end

  def approx_equals(%LatLng{}, %LatLng{} = other, max_error=1) do

  end

  def get_distance(%LatLng{} = latlng, %LatLng{} = other) do

  end
end
