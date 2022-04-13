defmodule Chess.Moves.Generators.DiagonalsTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Moves.Generators.Diagonals

  describe "c:generate/1" do
    test "given starting index at {4, 4}, returns a list of sets along all diagonals" do
      starting_index = Board.coordinates_to_index({4, 4})

      assert [_quadrant_1, _quadrant_2, _quadrant_3, _quadrant_4] =
               Diagonals.generate(starting_index)
    end
  end
end
