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

    test "allows knights in the lower left corner 2 potential moves" do
      board = BoardHelpers.empty_board()
      starting_index = 56
      piece = %Piece{type: Knight}
      square = :array.get(starting_index, board.board)
      square = %Square{square | piece: piece}
      board = %Board{board: :array.set(starting_index, square, board.board)}

      assert MapSet.new([41, 50]) == Knight.potential_moves(piece, starting_index, board)
    end

    test "allows knights in the upper left corner 2 potential moves" do
      board = BoardHelpers.empty_board()
      starting_index = 0
      piece = %Piece{type: Knight}
      square = :array.get(starting_index, board.board)
      square = %Square{square | piece: piece}
      board = %Board{board: :array.set(starting_index, square, board.board)}

      assert MapSet.new([10, 17]) == Knight.potential_moves(piece, starting_index, board)
    end

    test "allows knights in the upper right corner 2 potential moves" do
      board = BoardHelpers.empty_board()
      starting_index = 7
      piece = %Piece{type: Knight}
      square = :array.get(starting_index, board.board)
      square = %Square{square | piece: piece}
      board = %Board{board: :array.set(starting_index, square, board.board)}

      assert MapSet.new([13, 22]) == Knight.potential_moves(piece, starting_index, board)
    end

    test "allows knights in column 1 in the middle of the board 4 moves" do
      board = BoardHelpers.empty_board()
      starting_index = Board.coordinates_to_index({1, 4})
      piece = %Piece{type: Knight}
      square = :array.get(starting_index, board.board)
      square = %Square{square | piece: piece}
      board = %Board{board: :array.set(starting_index, square, board.board)}

      assert MapSet.new([9, 18, 34, 41]) == Knight.potential_moves(piece, starting_index, board)
    end

    test "allows knights in column 8 in the middle of the board 4 moves" do
      board = BoardHelpers.empty_board()
      # Starting index => 31
      starting_index = Board.coordinates_to_index({8, 4})
      piece = %Piece{type: Knight}
      square = :array.get(starting_index, board.board)
      square = %Square{square | piece: piece}
      board = %Board{board: :array.set(starting_index, square, board.board)}

      assert MapSet.new([14, 21, 37, 46]) == Knight.potential_moves(piece, starting_index, board)
    end
  end
end
