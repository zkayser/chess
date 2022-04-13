defmodule Chess.Moves.Generators.PerpendicularsTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Moves.Generators.Perpendiculars

  describe "c:generate/1" do
    test "given starting index at {4, 4}, returns a list of sets along all perpendicals" do
      starting_index = Board.coordinates_to_index({4, 4})

      assert [_laterals, _verticals] = Perpendiculars.generate(starting_index)
    end
  end
end
