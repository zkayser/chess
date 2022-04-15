defmodule Chess.Moves.Generators.DiagonalsTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Moves.Generators.Diagonals

  describe "c:generate/1" do
    test "given starting index at {4, 4}, returns a list of sets along all diagonals" do
      starting_index = Board.coordinates_to_index({4, 4})

      assert [quadrant_1, quadrant_2, quadrant_3, quadrant_4] = Diagonals.generate(starting_index)

      assert [{3, 3}, {2, 2}, {1, 1}] == quadrant_1
      assert [{5, 3}, {6, 2}, {7, 1}] == quadrant_2
      assert [{3, 5}, {2, 6}, {1, 7}] == quadrant_3
      assert [{5, 5}, {6, 6}, {7, 7}, {8, 8}] == quadrant_4
    end

    test "given starting index at {1, 1}, returns only a single populated quadrant" do
      assert quadrants = Diagonals.generate(Board.coordinates_to_index({1, 1}))

      assert [quadrant] = Enum.reject(quadrants, fn quadrant -> Enum.empty?(quadrant) end)

      expected = for position <- 2..8, do: {position, position}

      assert expected == quadrant
    end

    test "given starting index at {8, 8}, returns only a single populated quadrant" do
      assert quadrants = Diagonals.generate(Board.coordinates_to_index({8, 8}))

      assert [quadrant] = Enum.reject(quadrants, fn quadrant -> Enum.empty?(quadrant) end)

      expected = Enum.sort(for(position <- 1..7, do: {position, position}), :desc)

      assert expected == quadrant
    end

    test "given starting index at {1, 8}, returns only a single populated quadrant" do
      assert quadrants = Diagonals.generate(Board.coordinates_to_index({1, 8}))

      assert [quadrant] = Enum.reject(quadrants, fn quadrant -> Enum.empty?(quadrant) end)

      assert [{2, 7}, {3, 6}, {4, 5}, {5, 4}, {6, 3}, {7, 2}, {8, 1}] == quadrant
    end

    test "given starting index at {8, 1}, returns only a single populated quadrant" do
      assert quadrants = Diagonals.generate(Board.coordinates_to_index({8, 1}))

      assert [quadrant] = Enum.reject(quadrants, fn quadrant -> Enum.empty?(quadrant) end)

      assert [{7, 2}, {6, 3}, {5, 4}, {4, 5}, {3, 6}, {2, 7}, {1, 8}] == quadrant
    end
  end
end
