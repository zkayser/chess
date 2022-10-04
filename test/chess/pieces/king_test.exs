defmodule Chess.Pieces.KingTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Game
  alias Chess.Piece
  alias Chess.Pieces.King
  alias Chess.Test.BoardHelpers

  describe "potential_moves/3 with empty board" do
    for corner <- [{1, 1}, {1, 8}, {8, 1}, {8, 8}] do
      test "allows king in corner spot #{inspect(corner)} to move three spots" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(corner))
        king = %Piece{type: King}

        board = %Board{grid: :array.set(starting_index, king, board.grid)}

        assert Enum.count(King.potential_moves(king, starting_index, board)) == 3
      end
    end

    for vertical_edge <- for(x <- 2..7, y <- [1, 8], do: {x, y}) do
      test "allows king along vertical edge #{inspect(vertical_edge)} to move five spots" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(vertical_edge))
        king = %Piece{type: King}

        board = %Board{grid: :array.set(starting_index, king, board.grid)}

        assert Enum.count(King.potential_moves(king, starting_index, board)) == 5
      end
    end

    for horizontal_edge <- for(x <- [1, 8], y <- 2..7, do: {x, y}) do
      test "allows king along horizontal edge #{inspect(horizontal_edge)} to move five spots" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(horizontal_edge))
        king = %Piece{type: King}

        board = %Board{grid: :array.set(starting_index, king, board.grid)}

        assert Enum.count(King.potential_moves(king, starting_index, board)) == 5
      end
    end

    for middle <- for(x <- 2..7, y <- 2..7, do: {x, y}) do
      test "allows king on middle coordinate #{inspect(middle)} to move eight spots" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(middle))
        king = %Piece{type: King}

        board = %Board{grid: :array.set(starting_index, king, board.grid)}

        assert Enum.count(King.potential_moves(king, starting_index, board)) == 8
      end
    end

    test "does not allow a king to move itself into check" do
      board = BoardHelpers.empty_board()
      starting_index = 4
      king = %Piece{color: :white, type: King}
      opposing_knight = %Piece{color: :black, type: Chess.Pieces.Knight}

      board = %Board{grid: :array.set(starting_index, king, board.grid)}
      board = %Board{board | grid: :array.set(29, opposing_knight, board.grid)}

      # The opposing knight at index 29 would be able to reach index 12 if
      # the king decides to move up one row. Thus, index 29 should NOT be
      # included in the list of potential moves for the king.
      potential_moves = King.potential_moves(king, starting_index, board)
      refute MapSet.member?(potential_moves, 12)
    end

    test "does not allow a king to move itself into check default board" do
      game = Game.new()
      white_king = game.board[60]
      black_king = game.board[4]

      assert MapSet.new([51, 52, 53, 59, 61]) ==
               King.potential_moves(white_king, 60, game.board)

      assert MapSet.new([3, 5, 11, 12, 13]) == King.potential_moves(black_king, 4, game.board)
    end
  end
end
