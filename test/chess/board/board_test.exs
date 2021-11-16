defmodule Chess.BoardTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Board.Square
  alias Chess.Piece

  describe "layout/0" do
    test "creates a board of 64 squares" do
      board = Board.layout()
      assert :array.size(board) == 64
      :array.map(fn _, square -> match?(%Square{}, square) end, board)
    end

    test "places chess pieces on squares 0 through 15 and 48 through 63" do
      board = Board.layout()
      for non_empty_square <- Enum.concat(0..15, 48..63) do
        assert %Square{piece: %Piece{}} = :array.get(non_empty_square, board)
      end
    end

    test "square 16 through 47 are empty" do
      board = Board.layout()
      for empty_square <- 16..47 do
        assert %Square{piece: nil} = :array.get(empty_square, board)
      end
    end
  end
end
