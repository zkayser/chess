defmodule Chess.Bitboards.MoveTest do
  use ExUnit.Case, async: true

  alias Chess.Bitboards.Move

  describe "flags/0" do
    test "returns the list of all possible move flags" do
      expected_flags = ~w(
        quiet
        double_pawn_push
        king_castle
        queen_castle
        captures
        en_passant_captures
        knight_promotion
        bishop_promotion
        rook_promotion
        queen_promotion
        knight_promotion_capture
        bishop_promotion_capture
        rook_promotion_capture
        queen_promotion_capture
      )a

      assert MapSet.equal?(MapSet.new(expected_flags), MapSet.new(Move.flags())),
             """
             Expected the set of expected flags:
             #{inspect(expected_flags)}
             to be exactly equal to the set of flags returned from `Move.flags/0`:

             #{inspect(Move.flags())}
             """
    end
  end
end
