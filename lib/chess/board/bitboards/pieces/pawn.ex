defmodule Chess.BitBoards.Pieces.Pawn do
  @moduledoc """
  Functions for calculating pawn single and double pushes,
  attacks, pseudo-legal moves, and legal moves.
  """
  use Bitwise

  alias Chess.Boards.BitBoard
  alias Chess.Color

  @single_push 8
  @double_push 16
  @far_attack 9
  @near_attack 7
  @file_a_mask 0b01111111
  @file_h_mask 0b11111110
  @full_file_a_mask <<@file_a_mask, @file_a_mask, @file_a_mask, @file_a_mask, @file_a_mask,
                      @file_a_mask, @file_a_mask, @file_a_mask>>
  @full_file_h_mask <<@file_h_mask, @file_h_mask, @file_h_mask, @file_h_mask, @file_h_mask,
                      @file_h_mask, @file_h_mask, @file_h_mask>>

  @spec single_pushes(BitBoard.t(), Color.t()) :: BitBoard.bitboard()
  def single_pushes(bitboard, color) do
    bitboard
    |> BitBoard.get_raw(String.to_existing_atom("#{color}_pawns"))
    |> operation(color).(@single_push)
    |> BitBoard.from_integer()
  end

  @spec double_pushes(BitBoard.t(), Color.t()) :: BitBoard.bitboard()
  def double_pushes(bitboard, color) do
    bitboard
    |> BitBoard.get_raw(String.to_existing_atom("#{color}_pawns"))
    |> operation(color).(@double_push)
    |> BitBoard.from_integer()
  end

  @spec potential_attacks(BitBoard.t(), Color.t()) :: BitBoard.bitboard()
  def potential_attacks(bitboard, color) do
    bitboard = BitBoard.get_raw(bitboard, String.to_existing_atom("#{color}_pawns"))

    <<file_a_mask::integer-size(64)>> = @full_file_a_mask
    <<file_h_mask::integer-size(64)>> = @full_file_h_mask

    north_west_or_south_west = bitboard &&& file_a_mask
    north_east_or_south_east = bitboard &&& file_h_mask

    case color do
      :white ->
        BitBoard.from_integer(
          north_west_or_south_west <<< @far_attack ||| north_east_or_south_east <<< @near_attack
        )

      :black ->
        BitBoard.from_integer(
          north_west_or_south_west >>> @near_attack ||| north_east_or_south_east >>> @far_attack
        )
    end
  end

  defp operation(:black), do: &Bitwise.>>>/2
  defp operation(:white), do: &Bitwise.<<</2
end
