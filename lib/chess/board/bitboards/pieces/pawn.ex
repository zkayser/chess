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

  @spec single_pushes(BitBoard.t(), Color.t()) :: BitBoard.bitboard()
  def single_pushes(bitboard, color) do
    bitboard
    |> BitBoard.get(:"#{color}_pawns")
    |> operation(color).(@single_push)
  end

  @spec double_pushes(BitBoard.t(), Color.t()) :: BitBoard.bitboard()
  def double_pushes(bitboard, color) do
    bitboard
    |> BitBoard.get(:"#{color}_pawns")
    |> operation(color).(@double_push)
  end

  defp operation(:black), do: &Bitwise.>>>/2
  defp operation(:white), do: &Bitwise.<<</2
end
