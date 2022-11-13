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
end
