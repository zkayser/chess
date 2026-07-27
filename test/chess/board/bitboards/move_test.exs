defmodule Chess.Bitboards.MoveTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Chess.Bitboards.Move
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
  alias Chess.Game

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

  describe "make/3" do
    test "builds a quiet move when the destination is empty" do
      game = game_with([{{:white, :king}, {"e", 1}}])

      assert %Move{from: {"e", 1}, to: {"e", 2}, flag: :quiet} =
               Move.make(game, {"e", 1}, {"e", 2})
    end

    test "builds a capture when the destination has an opponent piece" do
      game =
        game_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :pawns}, {"f", 2}}
        ])

      assert %Move{from: {"e", 1}, to: {"f", 2}, flag: :captures} =
               Move.make(game, {"e", 1}, {"f", 2})
    end

    test "builds a quiet move when the destination has a friendly piece" do
      game =
        game_with([
          {{:white, :king}, {"e", 1}},
          {{:white, :pawns}, {"e", 2}}
        ])

      assert %Move{from: {"e", 1}, to: {"e", 2}, flag: :quiet} =
               Move.make(game, {"e", 1}, {"e", 2})
    end
  end

  describe "make/4" do
    test "uses the explicit flag" do
      game = game_with([{{:white, :king}, {"e", 1}}])

      assert %Move{from: {"e", 1}, to: {"g", 1}, flag: :king_castle} =
               Move.make(game, {"e", 1}, {"g", 1}, :king_castle)
    end
  end

  describe "encode/1 and decode/1" do
    property "returns an integer between 0 and 65536 for any valid move" do
      check all(move <- move_generator()) do
        assert Move.encode(move) in 0..65_536
      end
    end

    property "all encoded moves can be reversed by decoding" do
      check all(move <- move_generator()) do
        encoded = Move.encode(move)

        assert {:ok, decoded_move} = Move.decode(encoded)

        assert move == decoded_move, """
        Expected initial move #{inspect(move)}
        to be recovered by decoding the encoding #{inspect(Integer.digits(encoded, 2))},
        but this process failed.
        """
      end
    end
  end

  def move_generator do
    gen all(
          from <-
            StreamData.tuple(
              {StreamData.string(?a..?h, min_length: 1, max_length: 1), StreamData.integer(1..8)}
            ),
          to <-
            StreamData.tuple(
              {StreamData.string(?a..?h, min_length: 1, max_length: 1), StreamData.integer(1..8)}
            ),
          flag <- StreamData.one_of(Move.flags())
        ) do
      %Move{
        from: from,
        to: to,
        flag: flag
      }
    end
  end

  defp game_with(pieces) do
    %Game{board: board_with(pieces)}
  end

  defp board_with(pieces) do
    empty = BitBoard.empty()

    empty_pieces = %{
      pawns: empty,
      rooks: empty,
      knights: empty,
      bishops: empty,
      queens: empty,
      king: empty
    }

    Enum.reduce(pieces, %BitBoard{white: empty_pieces, black: empty_pieces}, fn
      {{color, piece_type}, square}, board ->
        put_in(board[{color, piece_type}], BitBoard.from_integer(Square.bitboard(square)))
    end)
  end
end
