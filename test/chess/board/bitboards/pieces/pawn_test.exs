defmodule Chess.BitBoards.Pieces.PawnTest do
  use ExUnit.Case, async: true

  alias Chess.Boards.BitBoard
  alias Chess.BitBoards.Pieces.Pawn

  describe "single_pushes/2" do
    test "given an initial state Bitboard.t/0 and white color, pushes all pawns up one rank" do
      bitboard = BitBoard.new()
      single_pushes = Pawn.single_pushes(bitboard, :white)

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(single_pushes)
    end
  end
end