defmodule Chess.Bitboards.AttacksTest do
  use ExUnit.Case, async: true

  import Bitwise

  alias Chess.Bitboards.Attacks
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square

  @king_deltas [
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, -1},
    {0, 1},
    {1, -1},
    {1, 0},
    {1, 1}
  ]

  @knight_deltas [
    {1, 2},
    {2, 1},
    {-1, 2},
    {-2, 1},
    {1, -2},
    {2, -1},
    {-1, -2},
    {-2, -1}
  ]

  describe "square_attacked_by?/3" do
    test "detects adjacent king attacks" do
      board =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :king}, {"e", 5}}
        ])

      assert Attacks.square_attacked_by?(board, :black, Square.mask({"e", 4}))
    end

    test "detects knight attacks without wraparound from the a-file" do
      board =
        board_with([
          {{:white, :king}, {"a", 4}},
          {{:black, :knights}, {"b", 6}}
        ])

      assert Attacks.square_attacked_by?(board, :black, Square.mask({"a", 4}))

      # Knight on h5 must not wrap and appear to attack a4.
      wrapped =
        board_with([
          {{:white, :king}, {"a", 4}},
          {{:black, :knights}, {"h", 5}}
        ])

      refute Attacks.square_attacked_by?(wrapped, :black, Square.mask({"a", 4}))
    end

    test "detects black pawn attacks and ignores the wrong direction" do
      attacked =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :pawns}, {"d", 5}}
        ])

      assert Attacks.square_attacked_by?(attacked, :black, Square.mask({"e", 4}))

      behind =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :pawns}, {"d", 3}}
        ])

      refute Attacks.square_attacked_by?(behind, :black, Square.mask({"e", 4}))
    end

    test "detects white pawn reverse attacks" do
      board =
        board_with([
          {{:black, :king}, {"e", 5}},
          {{:white, :pawns}, {"d", 4}}
        ])

      assert Attacks.square_attacked_by?(board, :white, Square.mask({"e", 5}))
    end

    test "detects rook attacks and stops at the first blocker" do
      open_file =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :rooks}, {"e", 8}}
        ])

      assert Attacks.square_attacked_by?(open_file, :black, Square.mask({"e", 1}))

      blocked =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:white, :pawns}, {"e", 2}},
          {{:black, :rooks}, {"e", 8}}
        ])

      refute Attacks.square_attacked_by?(blocked, :black, Square.mask({"e", 1}))
    end

    test "detects bishop and queen diagonal attacks" do
      bishop =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :bishops}, {"b", 4}}
        ])

      assert Attacks.square_attacked_by?(bishop, :black, Square.mask({"e", 1}))

      queen =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :queens}, {"e", 8}}
        ])

      assert Attacks.square_attacked_by?(queen, :black, Square.mask({"e", 4}))
    end

    test "returns false when no attacker hits the square" do
      board = board_with([{{:white, :king}, {"e", 1}}])

      refute Attacks.square_attacked_by?(board, :black, Square.mask({"e", 1}))
    end

    test "accepts a mask built from a square index" do
      board =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :rooks}, {"e", 8}}
        ])

      mask = Square.mask_from_index(Square.to_index({"e", 1}))
      assert Attacks.square_attacked_by?(board, :black, mask)
    end
  end

  describe "mask_attacked_by?/3" do
    test "returns true when any square in the mask is attacked" do
      board = board_with([{{:black, :bishops}, {"a", 6}}])
      mask = Square.bitboard({"e", 1}) ||| Square.bitboard({"f", 1}) ||| Square.bitboard({"g", 1})

      assert Attacks.mask_attacked_by?(board, :black, mask)
    end

    test "returns false when the mask is clear of attacks" do
      board = board_with([{{:black, :rooks}, {"a", 8}}])
      mask = Square.bitboard({"e", 1}) ||| Square.bitboard({"f", 1}) ||| Square.bitboard({"g", 1})

      refute Attacks.mask_attacked_by?(board, :black, mask)
    end

    test "agrees with square_attacked_by?/3 for a single-square mask" do
      board =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :rooks}, {"e", 8}}
        ])

      assert Attacks.mask_attacked_by?(board, :black, Square.mask({"e", 1}))
      assert Attacks.square_attacked_by?(board, :black, Square.mask({"e", 1}))
      refute Attacks.mask_attacked_by?(board, :black, Square.mask({"f", 1}))
    end
  end

  describe "king_attacks/1" do
    test "matches coordinate-delta attack sets for every square index" do
      for square_index <- 0..63 do
        square = Square.from_bitboard(1 <<< square_index)
        expected = attacks_from_deltas(square, @king_deltas)

        assert Attacks.king_attacks(square_index) == expected,
               "king attacks mismatch at index #{square_index} (#{inspect(square)})"
      end
    end

    test "corner king on h1 attacks three squares" do
      # h1 = index 0; attacks g1, g2, h2
      assert Attacks.king_attacks(0) ==
               (Square.bitboard({"g", 1}) ||| Square.bitboard({"g", 2}) |||
                  Square.bitboard({"h", 2}))
    end

    test "central king on e4 attacks all eight neighbors" do
      e4 = square_index({"e", 4})

      expected =
        [
          {"d", 3},
          {"d", 4},
          {"d", 5},
          {"e", 3},
          {"e", 5},
          {"f", 3},
          {"f", 4},
          {"f", 5}
        ]
        |> Enum.map(&Square.bitboard/1)
        |> Enum.reduce(0, &|||/2)

      assert Attacks.king_attacks(e4) == expected
    end
  end

  describe "knight_attacks/1" do
    test "matches coordinate-delta attack sets for every square index" do
      for square_index <- 0..63 do
        square = Square.from_bitboard(1 <<< square_index)
        expected = attacks_from_deltas(square, @knight_deltas)

        assert Attacks.knight_attacks(square_index) == expected,
               "knight attacks mismatch at index #{square_index} (#{inspect(square)})"
      end
    end

    test "corner knight on a1 has two attacks" do
      a1 = square_index({"a", 1})

      assert Attacks.knight_attacks(a1) ==
               (Square.bitboard({"b", 3}) ||| Square.bitboard({"c", 2}))
    end

    test "does not wrap from the a-file to the h-file" do
      a4 = square_index({"a", 4})
      attacks = Attacks.knight_attacks(a4)

      refute (attacks &&& Square.bitboard({"h", 5})) != 0
      refute (attacks &&& Square.bitboard({"h", 3})) != 0
      assert (attacks &&& Square.bitboard({"b", 6})) != 0
      assert (attacks &&& Square.bitboard({"c", 5})) != 0
    end
  end

  defp attacks_from_deltas(square, deltas) do
    Enum.reduce(deltas, 0, fn delta, acc ->
      case Square.try_delta(square, delta) do
        {:ok, target} -> acc ||| Square.bitboard(target)
        :error -> acc
      end
    end)
  end

  defp square_index(square) do
    bits = Square.bitboard(square)
    trailing_zeros(bits)
  end

  defp trailing_zeros(n), do: trailing_zeros(n, 0)
  defp trailing_zeros(n, index) when (n &&& 1) == 1, do: index
  defp trailing_zeros(n, index), do: trailing_zeros(n >>> 1, index + 1)

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
