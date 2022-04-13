defmodule Chess.Moves.Generators.PerpendicularsTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Moves.Generators.Perpendiculars

  describe "c:generate/1" do
    test "given starting index at {4, 4}, returns a list of sets along all perpendicals" do
      starting_index = Board.coordinates_to_index({4, 4})

      assert [{left, right} = _laterals, {below, above} = _verticals] =
               Perpendiculars.generate(starting_index)

      assert [{3, 4}, {2, 4}, {1, 4}] == left
      assert [{5, 4}, {6, 4}, {7, 4}, {8, 4}] == right
      assert [{4, 3}, {4, 2}, {4, 1}] == below
      assert [{4, 5}, {4, 6}, {4, 7}, {4, 8}] == above
    end
  end
end
