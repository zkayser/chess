defmodule Chess.Pieces.KingTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Piece
  alias Chess.Pieces.King
  alias Chess.Test.BoardHelpers

  describe "potential_moves/3 with empty board" do
    for corner <- [{1, 1}, {1, 8}, {8, 1}, {8, 8}] do
      test "allows king in corner spot #{inspect(corner)} to move three spots" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(corner))
        king = %Piece{type: King}

        board = %Board{board: :array.set(starting_index, king, board.board)}

        assert Enum.count(King.potential_moves(king, starting_index, board)) == 3
      end
    end

    for vertical_edge <- for(x <- 2..7, y <- [1, 8], do: {x, y}) do
      test "allows king along vertical edge #{inspect(vertical_edge)} to move five spots" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(vertical_edge))
        king = %Piece{type: King}

        board = %Board{board: :array.set(starting_index, king, board.board)}

        assert Enum.count(King.potential_moves(king, starting_index, board)) == 5
      end
    end

    for horizontal_edge <- for(x <- [1, 8], y <- 2..7, do: {x, y}) do
      test "allows king along horizontal edge #{inspect(horizontal_edge)} to move five spots" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(horizontal_edge))
        king = %Piece{type: King}

        board = %Board{board: :array.set(starting_index, king, board.board)}

        assert Enum.count(King.potential_moves(king, starting_index, board)) == 5
      end
    end

    for middle <- for(x <- 2..7, y <- 2..7, do: {x, y}) do
      test "allows king on middle coordinate #{inspect(middle)} to move eight spots" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(middle))
        king = %Piece{type: King}

        board = %Board{board: :array.set(starting_index, king, board.board)}

        assert Enum.count(King.potential_moves(king, starting_index, board)) == 8
      end
    end
  end
end
