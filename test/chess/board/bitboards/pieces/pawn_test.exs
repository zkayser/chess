defmodule Chess.BitBoards.Pieces.PawnTest do
  use ExUnit.Case, async: true

  alias Chess.BitBoards.Pieces.Pawn
  alias Chess.Boards.BitBoard
  alias Chess.Color

  describe "single_pushes/2" do
    test "given an initial state Bitboard.t/0 and white color, pushes all pawns up one rank" do
      bitboard = BitBoard.new()
      single_pushes = Pawn.single_pushes(bitboard, Color.white())

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

    test "given an initial state Bitboard.t/0 and black color, pushes all pawns down one rank" do
      bitboard = BitBoard.new()
      single_pushes = Pawn.single_pushes(bitboard, Color.black())

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(single_pushes)
    end
  end

  describe "double_pushes/2" do
    test "given an initial state Bitboard.t/0 and white color, pushes all pawns up two ranks" do
      bitboard = BitBoard.new()
      double_pushes = Pawn.double_pushes(bitboard, Color.white())

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(double_pushes)
    end

    test "given an initial state Bitboard.t/0 and black color, pushes all pawns down two ranks" do
      bitboard = BitBoard.new()
      double_pushes = Pawn.double_pushes(bitboard, Color.black())

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(double_pushes)
    end
  end

  describe "potential_attacks/2" do
    test "given an initial state bitboard and white's turn, masks the existing pawns on file A and H when presenting attacks" do
      bitboard = BitBoard.new()
      potential_attacks = Pawn.potential_attacks(bitboard, Color.white())

      assert assert [
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [1, 1, 1, 1, 1, 1, 1, 1],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0]
                    ] == BitBoard.to_grid(potential_attacks)
    end

    test "given an initial state bitboard and black's turn, masks the existing pawns on files A and H when presenting attacks" do
      bitboard = BitBoard.new()
      potential_attacks = Pawn.potential_attacks(bitboard, Color.black())

      assert assert [
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [1, 1, 1, 1, 1, 1, 1, 1],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0]
                    ] == BitBoard.to_grid(potential_attacks)
    end
  end
end
