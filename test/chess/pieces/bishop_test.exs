defmodule Chess.Pieces.BishopTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Piece
  alias Chess.Pieces.Bishop
  alias Chess.Test.BoardHelpers

  describe "potential_moves/3 with empty board" do
    setup do
      {:ok, board: BoardHelpers.empty_board()}
    end

    for [corner_position, potential_move] <-
          for(
            corner <- [{1, 1}, {8, 8}],
            candidate <- Enum.map(1..8, fn x -> {x, x} end),
            candidate != corner,
            do: [corner, candidate]
          ) do
      test "allows bishop starting at corner position #{inspect(corner_position)} to move to #{inspect(potential_move)}",
           %{board: board} do
        bishop = %Piece{type: Bishop}
        starting_index = Board.coordinates_to_index(unquote(corner_position))
        board = %Board{board | grid: :array.set(starting_index, bishop, board.grid)}

        potential_moves = Bishop.potential_moves(bishop, starting_index, board)
        expected_index = Board.coordinates_to_index(unquote(potential_move))

        assert MapSet.member?(potential_moves, expected_index),
               "Expected #{inspect(expected_index)} (coordinate #{inspect(unquote(potential_move))}) to be in #{inspect(potential_moves)}, but it was not. \nInstead got #{inspect(Enum.map(potential_moves, fn m -> Board.index_to_coordinates(m) end))}"
      end
    end

    test "allows a bishop starting at position {4, 4} to move all along diagonals", %{
      board: board
    } do
      bishop = %Piece{type: Bishop}
      starting_index = Board.coordinates_to_index({4, 4})
      board = %Board{board | grid: :array.set(starting_index, bishop, board.grid)}

      potential_moves = Bishop.potential_moves(bishop, starting_index, board)

      diagonal_1 = [{1, 1}, {2, 2}, {3, 3}, {5, 5}, {6, 6}, {7, 7}, {8, 8}]
      diagonal_2 = [{5, 3}, {6, 2}, {7, 1}, {3, 5}, {2, 6}, {1, 7}]

      expected =
        diagonal_1
        |> Enum.concat(diagonal_2)
        |> Enum.map(fn coords -> Board.coordinates_to_index(coords) end)
        |> MapSet.new()

      assert MapSet.equal?(potential_moves, expected),
             "Expected potential moves #{inspect(potential_moves)}\nto equal\n#{inspect(expected)}"
    end
  end
end
