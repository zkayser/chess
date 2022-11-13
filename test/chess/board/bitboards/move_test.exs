defmodule Chess.Bitboards.MoveTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

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

  describe "encode/1" do
    property "returns an integer between 0 and 256 for any valid move" do
      check all(move <- move_generator()) do
        assert Move.encode(move) in 0..256
      end
    end
  end

  def move_generator() do
    gen all(
          from <-
            StreamData.tuple(
              {StreamData.string(?a..?h, min_length: 1, max_length: 1), StreamData.integer(1..8)}
            ),
          to <-
            StreamData.tuple(
              {StreamData.string(?a..?h, min_length: 1, max_length: 1), StreamData.integer(1..8)}
            ),
          flag <- StreamData.one_of(Move.flags()),
          from != to
        ) do
      %Move{
        from: from,
        to: to,
        flag: flag
      }
    end
  end
end
