defmodule Chess.Bitboards.CastlingTest do
  use ExUnit.Case, async: true

  import Bitwise

  alias Chess.Bitboards.Castling
  alias Chess.Boards.Bitboards.Square

  describe "path_clear?/3" do
    test "returns true when the kingside path is empty" do
      assert Castling.path_clear?(0, :white, :kingside)
    end

    test "returns false when any kingside path square is occupied" do
      occupied = Square.bitboard({"f", 1})

      refute Castling.path_clear?(occupied, :white, :kingside)
    end

    test "returns false when any queenside path square is occupied" do
      occupied = Square.bitboard({"b", 1})

      refute Castling.path_clear?(occupied, :white, :queenside)
    end

    test "ignores occupancy outside the castling path" do
      occupied = Square.bitboard({"a", 2}) ||| Square.bitboard({"h", 8})

      assert Castling.path_clear?(occupied, :white, :kingside)
      assert Castling.path_clear?(occupied, :white, :queenside)
    end
  end

  describe "path_mask/2" do
    test "is the bitwise OR of each path square" do
      expected = Square.bitboard({"f", 1}) ||| Square.bitboard({"g", 1})

      assert Castling.path_mask(:white, :kingside) == expected
    end
  end

  describe "transit_mask/2" do
    test "is the bitwise OR of king start, pass-through, and landing squares" do
      expected =
        Square.bitboard({"e", 1}) ||| Square.bitboard({"f", 1}) ||| Square.bitboard({"g", 1})

      assert Castling.transit_mask(:white, :kingside) == expected
    end
  end

  describe "side/3" do
    test "classifies white kingside and queenside castling" do
      assert {:ok, :kingside} = Castling.side(:white, {"e", 1}, {"g", 1})
      assert {:ok, :queenside} = Castling.side(:white, {"e", 1}, {"c", 1})
    end

    test "rejects non-castling destinations from the king home square" do
      assert {:error, :cannot_castle} = Castling.side(:white, {"e", 1}, {"e", 2})
    end
  end
end
