defmodule Chess.Pieces.KnightTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Board.Square
  alias Chess.Piece
  alias Chess.Pieces.Knight
  alias Chess.Test.BoardHelpers

  describe "potential_moves/3 with empty board," do
    test "allows knights in the middle of the board 8 potential moves" do
      board = BoardHelpers.empty_board()
      starting_index = 35
      piece = %Piece{type: Knight}
      square = :array.get(starting_index, board.board)
      square = %Square{square | piece: piece}
      board = %Board{board: :array.set(starting_index, square, board.board)}

      assert MapSet.new([18, 20, 25, 29, 41, 45, 50, 52]) ==
               Knight.potential_moves(piece, starting_index, board)
    end

    test "allows knights in the lower right corner 2 potential moves" do
      board = BoardHelpers.empty_board()
      starting_index = 63
      piece = %Piece{type: Knight}
      square = :array.get(starting_index, board.board)
      square = %Square{square | piece: piece}
      board = %Board{board: :array.set(starting_index, square, board.board)}

      assert MapSet.new([46, 53]) == Knight.potential_moves(piece, starting_index, board)
    end
  end
end
