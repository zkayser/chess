defmodule Chess.Boards.BitBoardTest do
  use ExUnit.Case

  alias Chess.Boards.BitBoard

  describe "new/0" do
    test "creates a BitBoard struct with an atomics ref" do
      assert %BitBoard{ref: ref} = BitBoard.new()

      assert is_reference(ref),
             "Expected new bitboard to contain a reference, but contained #{inspect(ref)} instead."
    end
  end

  describe "to_list/2" do
    test "returns an 8x8 list representation of the composite bitboard" do
      bitboard = BitBoard.new()

      assert [
               [1, 1, 1, 1, 1, 1, 1, 1],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [1, 1, 1, 1, 1, 1, 1, 1]
             ] == BitBoard.to_list(bitboard, :composite)
    end
  end
end
