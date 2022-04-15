defmodule Chess.Moves.FiltersTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Moves.Filters
  alias Chess.Piece
  alias Chess.Pieces.Rook
  alias Chess.Test.BoardHelpers

  describe "unreachable_coordinates/3" do
    test "reduces a set of moves in one direction down to coordinates not blocked by a friendly piece" do
      board = BoardHelpers.empty_board()
      piece = %Piece{type: Rook, color: :white}
      friendly_piece = %Piece{type: Rook, color: :white}

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 1}), piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 4}), friendly_piece, board.grid)
      }

      potential_moves_set = for x <- 2..8, do: {1, x}

      expected_filtered_moves = [{1, 2}, {1, 3}]

      assert expected_filtered_moves ==
               Filters.unreachable_coordinates([potential_moves_set], piece, board)
    end
  end
end
