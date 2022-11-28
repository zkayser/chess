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
  @file_a_mask 0b0111111101111111011111110111111101111111011111110111111101111111
  @file_h_mask 0b1111111011111110111111101111111011111110111111101111111011111110

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
    bitboard
    |> BitBoard.get_raw(String.to_existing_atom("#{color}_pawns"))
    |> then(fn b -> {b &&& @file_a_mask, b &&& @file_h_mask} end)
    |> attack_quadrants(color).()
    |> BitBoard.from_integer()
  end

  defp operation(:black), do: &Bitwise.>>>/2
  defp operation(:white), do: &Bitwise.<<</2

  defp attack_quadrants(:white) do
    fn {north_west, north_east} ->
      north_west <<< @far_attack ||| north_east <<< @near_attack
    end
  end

  defp attack_quadrants(:black) do
    fn {south_west, south_east} ->
      south_west >>> @near_attack ||| south_east >>> @far_attack
    end
  end
end
