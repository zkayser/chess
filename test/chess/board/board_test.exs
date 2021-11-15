defmodule Chess.BoardTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Board.Square

  describe "layout/0" do
    test "creates a board of 64 squares" do
      board = Board.layout()
      assert :array.size(board) == 64
      :array.map(fn _, square -> match?(%Square{}, square) end, board)
    end
  end
end
