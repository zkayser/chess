defmodule Chess.Bitboards.Attacks do
  @moduledoc """
  Bitwise attack detection for chess bitboards.

  Given a target square, generates reverse-attack sets via shifts and file
  masks (and occupancy-aware slider rays), then intersects those sets with
  opponent piece bitboards. Prefer this over coordinate/`Enum` iteration for
  engine hot paths such as king-safety checks.

  For multi-square queries (e.g. castling transit), `attacks_by/2` builds the
  forward attack bitboard for a color so callers can AND it with a mask.

  King and knight attack sets are position-independent aside from board edges,
  so they are precomputed at compile time into 64-entry lookup tables keyed by
  square index.

  Bitboard layout matches the rest of the engine: bit 0 is h1, bit 7 is a1,
  bit 8 is h2, …, bit 63 is a8. Shifts toward the a-file increase the bit
  index; shifts toward the h-file decrease it.
  """

  import Bitwise

  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square

  # Same masks as `Chess.BitBoards.Pieces.Pawn` — clear a/h files so shifts
  # cannot wrap across the board edge.
  @file_a_mask 0b0111111101111111011111110111111101111111011111110111111101111111
  @file_h_mask 0b1111111011111110111111101111111011111110111111101111111011111110
  @file_ab_mask 0b0011111100111111001111110011111100111111001111110011111100111111
  @file_gh_mask 0b1111110011111100111111001111110011111100111111001111110011111100

  @not_rank_1 0b1111111111111111111111111111111111111111111111111111111100000000
  @not_rank_8 0b0000000011111111111111111111111111111111111111111111111111111111
  @not_rank_12 0b1111111111111111111111111111111111111111111111110000000000000000
  @not_rank_78 0b0000000000000000111111111111111111111111111111111111111111111111

  # Compile-time tables built with the same shift + file/rank mask formulas
  # previously evaluated at runtime. Index `n` holds attacks from bit `n`.
  @king_attacks (for square <- 0..63 do
                   bit = 1 <<< square

                   (bit &&& @file_a_mask &&& @not_rank_8) <<< 9 |||
                     (bit &&& @not_rank_8) <<< 8 |||
                     (bit &&& @file_h_mask &&& @not_rank_8) <<< 7 |||
                     (bit &&& @file_a_mask) <<< 1 |||
                     (bit &&& @file_h_mask) >>> 1 |||
                     (bit &&& @file_a_mask &&& @not_rank_1) >>> 7 |||
                     (bit &&& @not_rank_1) >>> 8 |||
                     (bit &&& @file_h_mask &&& @not_rank_1) >>> 9
                 end)
                |> List.to_tuple()

  @knight_attacks (for square <- 0..63 do
                     bit = 1 <<< square

                     (bit &&& @file_a_mask &&& @not_rank_78) <<< 17 |||
                       (bit &&& @file_h_mask &&& @not_rank_78) <<< 15 |||
                       (bit &&& @file_ab_mask &&& @not_rank_8) <<< 10 |||
                       (bit &&& @file_gh_mask &&& @not_rank_8) <<< 6 |||
                       (bit &&& @file_ab_mask &&& @not_rank_1) >>> 6 |||
                       (bit &&& @file_gh_mask &&& @not_rank_1) >>> 10 |||
                       (bit &&& @file_a_mask &&& @not_rank_12) >>> 15 |||
                       (bit &&& @file_h_mask &&& @not_rank_12) >>> 17
                   end)
                  |> List.to_tuple()

  @doc """
  Returns true if any piece of `attacker` color attacks `square`.
  """
  @spec square_attacked_by?(BitBoard.t(), Chess.player(), Square.t()) :: boolean()
  def square_attacked_by?(board, attacker, square) do
    target = Square.bitboard(square)
    occupied = BitBoard.get_raw(board, :full)

    attacked_by_king?(board, attacker, target) or
      attacked_by_knight?(board, attacker, target) or
      attacked_by_pawn?(board, attacker, target) or
      attacked_by_slider?(board, attacker, target, occupied)
  end

  @doc """
  Returns true if any square set in `mask` is attacked by `attacker`.

  Computes the forward attack bitboard for `attacker` and intersects it with
  `mask` via bitwise AND.
  """
  @spec mask_attacked_by?(BitBoard.t(), Chess.player(), integer()) :: boolean()
  def mask_attacked_by?(board, attacker, mask) when is_integer(mask) do
    (attacks_by(board, attacker) &&& mask) != 0
  end

  @doc """
  Bitboard of all squares attacked by pieces of `attacker` color.
  """
  @spec attacks_by(BitBoard.t(), Chess.player()) :: integer()
  def attacks_by(board, attacker) do
    occupied = BitBoard.get_raw(board, :full)

    ortho =
      BitBoard.get_raw(board, {attacker, :rooks}) ||| BitBoard.get_raw(board, {attacker, :queens})

    diag =
      BitBoard.get_raw(board, {attacker, :bishops}) |||
        BitBoard.get_raw(board, {attacker, :queens})

    attacks_from_kings(BitBoard.get_raw(board, {attacker, :king})) |||
      attacks_from_knights(BitBoard.get_raw(board, {attacker, :knights})) |||
      attacks_from_pawns(BitBoard.get_raw(board, {attacker, :pawns}), attacker) |||
      attacks_from_sliders(ortho, occupied, &rook_attacks/2) |||
      attacks_from_sliders(diag, occupied, &bishop_attacks/2)
  end

  @doc """
  Precomputed king attack bitboard for square index `0..63` (bit 0 = h1).
  """
  @spec king_attacks(0..63) :: integer()
  def king_attacks(square_index) when square_index in 0..63 do
    elem(@king_attacks, square_index)
  end

  @doc """
  Precomputed knight attack bitboard for square index `0..63` (bit 0 = h1).
  """
  @spec knight_attacks(0..63) :: integer()
  def knight_attacks(square_index) when square_index in 0..63 do
    elem(@knight_attacks, square_index)
  end

  defp attacked_by_king?(board, attacker, target) do
    (king_attacks(square_index(target)) &&& BitBoard.get_raw(board, {attacker, :king})) != 0
  end

  defp attacked_by_knight?(board, attacker, target) do
    (knight_attacks(square_index(target)) &&& BitBoard.get_raw(board, {attacker, :knights})) != 0
  end

  defp attacked_by_pawn?(board, attacker, target) do
    (pawn_attackers(attacker, target) &&& BitBoard.get_raw(board, {attacker, :pawns})) != 0
  end

  defp attacked_by_slider?(board, attacker, target, occupied) do
    ortho =
      BitBoard.get_raw(board, {attacker, :rooks}) ||| BitBoard.get_raw(board, {attacker, :queens})

    diag =
      BitBoard.get_raw(board, {attacker, :bishops}) |||
        BitBoard.get_raw(board, {attacker, :queens})

    (rook_attacks(target, occupied) &&& ortho) != 0 or
      (bishop_attacks(target, occupied) &&& diag) != 0
  end

  defp attacks_from_kings(bits) do
    (bits &&& @file_a_mask &&& @not_rank_8) <<< 9 |||
      (bits &&& @not_rank_8) <<< 8 |||
      (bits &&& @file_h_mask &&& @not_rank_8) <<< 7 |||
      (bits &&& @file_a_mask) <<< 1 |||
      (bits &&& @file_h_mask) >>> 1 |||
      (bits &&& @file_a_mask &&& @not_rank_1) >>> 7 |||
      (bits &&& @not_rank_1) >>> 8 |||
      (bits &&& @file_h_mask &&& @not_rank_1) >>> 9
  end

  defp attacks_from_knights(bits) do
    (bits &&& @file_a_mask &&& @not_rank_78) <<< 17 |||
      (bits &&& @file_h_mask &&& @not_rank_78) <<< 15 |||
      (bits &&& @file_ab_mask &&& @not_rank_8) <<< 10 |||
      (bits &&& @file_gh_mask &&& @not_rank_8) <<< 6 |||
      (bits &&& @file_ab_mask &&& @not_rank_1) >>> 6 |||
      (bits &&& @file_gh_mask &&& @not_rank_1) >>> 10 |||
      (bits &&& @file_a_mask &&& @not_rank_12) >>> 15 |||
      (bits &&& @file_h_mask &&& @not_rank_12) >>> 17
  end

  defp attacks_from_pawns(bits, :white) do
    (bits &&& @file_a_mask) <<< 9 ||| (bits &&& @file_h_mask) <<< 7
  end

  defp attacks_from_pawns(bits, :black) do
    (bits &&& @file_a_mask) >>> 7 ||| (bits &&& @file_h_mask) >>> 9
  end

  defp attacks_from_sliders(0, _occupied, _attack_fn), do: 0

  defp attacks_from_sliders(pieces, occupied, attack_fn) do
    bit = 1 <<< trailing_zeros(pieces)

    attack_fn.(bit, occupied) |||
      attacks_from_sliders(pieces &&& bnot(bit), occupied, attack_fn)
  end

  defp square_index(bit), do: trailing_zeros(bit)

  defp trailing_zeros(n), do: trailing_zeros(n, 0)
  defp trailing_zeros(n, index) when (n &&& 1) == 1, do: index
  defp trailing_zeros(n, index), do: trailing_zeros(n >>> 1, index + 1)

  # Squares from which a pawn of `attacker` color attacks `target`.
  # White pawns attack via <<<7 / <<<9; black via >>>7 / >>>9 (see Pawn).
  defp pawn_attackers(:white, target) do
    (target &&& @file_a_mask) >>> 7 ||| (target &&& @file_h_mask) >>> 9
  end

  defp pawn_attackers(:black, target) do
    (target &&& @file_a_mask) <<< 9 ||| (target &&& @file_h_mask) <<< 7
  end

  defp rook_attacks(bit, occupied) do
    ray_attacks(bit, occupied, &north/1) |||
      ray_attacks(bit, occupied, &south/1) |||
      ray_attacks(bit, occupied, &toward_a/1) |||
      ray_attacks(bit, occupied, &toward_h/1)
  end

  defp bishop_attacks(bit, occupied) do
    ray_attacks(bit, occupied, &northwest/1) |||
      ray_attacks(bit, occupied, &northeast/1) |||
      ray_attacks(bit, occupied, &southwest/1) |||
      ray_attacks(bit, occupied, &southeast/1)
  end

  # Walk occupancy in one direction: include empty squares along the ray and
  # the first occupied square (the blocker), then stop.
  defp ray_attacks(bit, occupied, step) do
    do_ray_attacks(step.(bit), occupied, step, 0)
  end

  defp do_ray_attacks(0, _occupied, _step, acc), do: acc

  defp do_ray_attacks(bit, occupied, step, acc) do
    acc = acc ||| bit

    if (bit &&& occupied) != 0 do
      acc
    else
      do_ray_attacks(step.(bit), occupied, step, acc)
    end
  end

  defp north(bit), do: (bit &&& @not_rank_8) <<< 8
  defp south(bit), do: (bit &&& @not_rank_1) >>> 8
  defp toward_a(bit), do: (bit &&& @file_a_mask) <<< 1
  defp toward_h(bit), do: (bit &&& @file_h_mask) >>> 1

  defp northwest(bit), do: (bit &&& @file_a_mask &&& @not_rank_8) <<< 9
  defp northeast(bit), do: (bit &&& @file_h_mask &&& @not_rank_8) <<< 7
  defp southwest(bit), do: (bit &&& @file_a_mask &&& @not_rank_1) >>> 7
  defp southeast(bit), do: (bit &&& @file_h_mask &&& @not_rank_1) >>> 9
end
