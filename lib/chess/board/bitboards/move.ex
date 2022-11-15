defmodule Chess.Bitboards.Move do
  @moduledoc """
  Module for working with encoded chess moves, where
  moves will be encoded as a series of bits according to
  the following structure:

  Bits 1..3 -> From file, with file a = 0 and file h = 7;
  in other words file a = `[0, 0, 0]` while file h = `[1, 1, 1]`
  in a binary, bitwise representation.

  Bits 4..6 -> From rank, with rank 1 = 0 and rank 8 = 56;
  in other words, rank 1 = `[0, 0, 0, 0, 0, 0]` and rank 8 =
  `[1, 1, 1, 0, 0, 0]`.

  Bits 7..9 -> To file, essentially the same as bits 1..3 except
  each file is left-shifted 6; i.e.:
  `[0, 0, 0, <from-rank-bits>, <from-file-bits>]` for a move to file a,
  `[1, 1, 1, <from-rank-bits>, <from-file-bits>]` for a move to file h

  Bits 10..12 -> To rank, essentially the same as bits 4..6 except with
  each rank left-shifted again by 6; i.e.:
  `[0, 0, 0, <to-file-bits>, <from-rank-bits>, <from-file-bits>]` for a move to rank 1,
  `[1, 1, 1, <to-file-bits>, <from-rank-bits>, <from-file-bits>]` for a move to rank 8.

  Bits 13..16 are flags, representing the following:

  0 -> quiet move
  1 -> double pawn push
  2 -> king castle
  3 -> queen castle
  4 -> captures
  5 -> en-passant captures
  8 -> knight promotion
  9 -> bishop promotion
  10 -> rook promotion
  11 -> queen promotion
  12 -> knight promotion capture
  13 -> bishop promotion capture
  14 -> rook promotion capture
  15 -> queen promotion capture
  """
  use Bitwise

  defstruct [:from, :to, :flag]

  @flag_codes %{
    quiet: 0,
    double_pawn_push: 1,
    king_castle: 2,
    queen_castle: 3,
    captures: 4,
    en_passant_captures: 5,
    knight_promotion: 8,
    bishop_promotion: 9,
    rook_promotion: 10,
    queen_promotion: 11,
    knight_promotion_capture: 12,
    bishop_promotion_capture: 13,
    rook_promotion_capture: 14,
    queen_promotion_capture: 15
  }

  @typedoc """
  A `coordinate` is a tuple representing the
  file (the first element of the tuple), which is
  a string in the range from "a" to "h", and the
  rank, which is an integer in the range 1..8.

  In chess, a file represents a column along the board,
  while a rank represent rows on the board.
  """
  @type coordinate() :: {String.t(), 1..8}

  @type t() :: %__MODULE__{
          from: coordinate(),
          to: coordinate(),
          flag: flag()
        }

  @typedoc """
  The set of all possible move flags.
  """
  @type flag() ::
          :quiet
          | :double_pawn_push
          | :king_castle
          | :queen_castle
          | :captures
          | :en_passant_captures
          | :knight_promotion
          | :bishop_promotion
          | :rook_promotion
          | :queen_promotion
          | :knight_promotion_capture
          | :bishop_promotion_capture
          | :rook_promotion_capture
          | :queen_promotion_capture

  @typedoc """
  An encoded move is a 16-bit integer, which means it has
  a decimal-based integer value of 0..65536.

  The first 6 bits of the integer represent the origin square
  from which a move is made.

  The second 6 bits of the integer represent the destination square
  to which a move is made.

  The remaining 4 bits of the integer represent a flag denoting
  the type of move, captures, promotions, etc. See the docs on
  `t:flag/0` for more information.
  """
  @type encoded() :: 0..65536

  @spec flags() :: list(flag())
  def flags, do: Map.keys(@flag_codes)

  @file_to_value ?a..?h |> Enum.with_index() |> Map.new(fn {k, v} -> {<<k>>, v} end)

  @spec encode(t()) :: encoded()
  def encode(%__MODULE__{from: {from_file, from_rank}, to: {to_file, to_rank}, flag: flag}) do
    @file_to_value[from_file]
    |> bor((from_rank - 1) <<< 3)
    |> bor(@file_to_value[to_file] <<< 6)
    |> bor((to_rank - 1) <<< 9)
    |> bor(@flag_codes[flag] <<< 12)
  end
end
