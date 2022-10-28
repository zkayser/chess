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
end
