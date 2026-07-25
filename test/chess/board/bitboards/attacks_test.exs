defmodule Chess.Bitboards.AttacksTest do
  use ExUnit.Case, async: true

  alias Chess.Bitboards.Attacks
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square

  describe "square_attacked_by?/3" do
    test "detects adjacent king attacks" do
      board =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :king}, {"e", 5}}
        ])

      assert Attacks.square_attacked_by?(board, :black, {"e", 4})
    end

    test "detects knight attacks without wraparound from the a-file" do
      board =
        board_with([
          {{:white, :king}, {"a", 4}},
          {{:black, :knights}, {"b", 6}}
        ])

      assert Attacks.square_attacked_by?(board, :black, {"a", 4})

      # Knight on h5 must not wrap and appear to attack a4.
      wrapped =
        board_with([
          {{:white, :king}, {"a", 4}},
          {{:black, :knights}, {"h", 5}}
        ])

      refute Attacks.square_attacked_by?(wrapped, :black, {"a", 4})
    end

    test "detects black pawn attacks and ignores the wrong direction" do
      attacked =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :pawns}, {"d", 5}}
        ])

      assert Attacks.square_attacked_by?(attacked, :black, {"e", 4})

      behind =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :pawns}, {"d", 3}}
        ])

      refute Attacks.square_attacked_by?(behind, :black, {"e", 4})
    end

    test "detects white pawn reverse attacks" do
      board =
        board_with([
          {{:black, :king}, {"e", 5}},
          {{:white, :pawns}, {"d", 4}}
        ])

      assert Attacks.square_attacked_by?(board, :white, {"e", 5})
    end

    test "detects rook attacks and stops at the first blocker" do
      open_file =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :rooks}, {"e", 8}}
        ])

      assert Attacks.square_attacked_by?(open_file, :black, {"e", 1})

      blocked =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:white, :pawns}, {"e", 2}},
          {{:black, :rooks}, {"e", 8}}
        ])

      refute Attacks.square_attacked_by?(blocked, :black, {"e", 1})
    end

    test "detects bishop and queen diagonal attacks" do
      bishop =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :bishops}, {"b", 4}}
        ])

      assert Attacks.square_attacked_by?(bishop, :black, {"e", 1})

      queen =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :queens}, {"e", 8}}
        ])

      assert Attacks.square_attacked_by?(queen, :black, {"e", 4})
    end

    test "returns false when no attacker hits the square" do
      board = board_with([{{:white, :king}, {"e", 1}}])

      refute Attacks.square_attacked_by?(board, :black, {"e", 1})
    end
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
