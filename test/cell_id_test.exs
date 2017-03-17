defmodule CellIdTest do
  use ExUnit.Case

  alias S2Sphere.CellId

  test "get_all_neighbors returns correct neighbors" do
    # cell level 16
    expected_cells = [5116992006467354624, 5116991746621833216, 5116992004856741888, 5116992002709258240, 5116992003783000064, 5116991747158704128, 5116992003246129152, 5116991748769316864] 
    |> Enum.map(&CellId.new/1)

    cells = %CellId{id: 5116992004319870976}
    |> CellId.get_all_neighbors(16)
    assert cells == expected_cells
  end
end
