defmodule Chess.Boards.Bitboards.SquareTest do
  use ExUnit.Case

  alias Chess.Boards.Bitboards.Square

  describe "try_delta/2" do
    test "returns an ok tuple with the new square when applying delta results in a valid square coordinate" do
      flunk("TODO")
    end

    test "returns :error when applying the delta results in a square that goes out of bounds" do
      flunk("TODO")
    end
  end

  describe "bitboard/1" do
    test "returns the bitboard representation of the given square" do
      flunk("TODO")
    end
  end
end
