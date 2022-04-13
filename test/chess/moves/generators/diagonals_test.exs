defmodule Chess.Moves.Generators.DiagonalsTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Moves.Generators.Diagonals

  describe "c:generate/1" do
    test "given starting index at {4, 4}, returns a list of sets along all diagonals" do
      starting_index = Board.coordinates_to_index({4, 4})

      assert [quadrant_1, quadrant_2, quadrant_3, quadrant_4] = Diagonals.generate(starting_index)

      assert MapSet.new([{3, 3}, {2, 2}, {1, 1}]) == quadrant_1
      assert MapSet.new([{5, 3}, {6, 2}, {7, 1}]) == quadrant_2
      assert MapSet.new([{3, 5}, {2, 6}, {1, 7}]) == quadrant_3
      assert MapSet.new([{5, 5}, {6, 6}, {7, 7}, {8, 8}]) == quadrant_4
    end
  end
end
