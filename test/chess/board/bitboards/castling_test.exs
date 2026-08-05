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
      occupied = Square.mask({"f", 1})

      refute Castling.path_clear?(occupied, :white, :kingside)
    end

    test "returns false when any queenside path square is occupied" do
      occupied = Square.mask({"b", 1})

      refute Castling.path_clear?(occupied, :white, :queenside)
    end

    test "ignores occupancy outside the castling path" do
      occupied = Square.mask({"a", 2}) ||| Square.mask({"h", 8})

      assert Castling.path_clear?(occupied, :white, :kingside)
      assert Castling.path_clear?(occupied, :white, :queenside)
    end
  end

  describe "path_mask/2" do
    test "is the bitwise OR of each path square" do
      expected = Square.mask({"f", 1}) ||| Square.mask({"g", 1})

      assert Castling.path_mask(:white, :kingside) == expected
    end
  end

  describe "transit_mask/2" do
    test "is the bitwise OR of king start, pass-through, and landing squares" do
      expected =
        Square.mask({"e", 1}) ||| Square.mask({"f", 1}) ||| Square.mask({"g", 1})

      assert Castling.transit_mask(:white, :kingside) == expected
    end
  end

  describe "home and destination masks" do
    test "king_home/1 returns the starting square mask" do
      assert Castling.king_home(:white) == Square.mask({"e", 1})
      assert Castling.king_home(:black) == Square.mask({"e", 8})
    end

    test "rook_home/2 and king_destination/2 return masks" do
      assert Castling.rook_home(:white, :kingside) == Square.mask({"h", 1})
      assert Castling.rook_home(:white, :queenside) == Square.mask({"a", 1})
      assert Castling.king_destination(:white, :kingside) == Square.mask({"g", 1})
      assert Castling.king_destination(:white, :queenside) == Square.mask({"c", 1})
    end
  end

  describe "side/3" do
    test "classifies white kingside and queenside castling by mask" do
      assert {:ok, :kingside} =
               Castling.side(:white, Square.mask({"e", 1}), Square.mask({"g", 1}))

      assert {:ok, :queenside} =
               Castling.side(:white, Square.mask({"e", 1}), Square.mask({"c", 1}))
    end

    test "rejects non-castling destinations from the king home square" do
      assert {:error, :cannot_castle} =
               Castling.side(:white, Square.mask({"e", 1}), Square.mask({"e", 2}))
    end
  end
end
