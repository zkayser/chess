defmodule Chess.Pieces.Pawn do
  @moduledoc """
  Represents a Pawn piece.
  """
  alias Chess.Board
  alias Chess.Piece

  @spec potential_moves(Piece.t(), position :: non_neg_integer(), Board.t()) ::
          MapSet.t(position :: non_neg_integer())
  def potential_moves(%Piece{color: color, moves: moves}, starting_position, board) do
    moves
    |> list_of_potential_moves(starting_position, color)
    |> Stream.filter(&Board.in_bounds?/1)
    |> Stream.reject(fn index -> :array.get(index, board) end)
    |> MapSet.new()
  end

  @spec list_of_potential_moves(list(non_neg_integer()), non_neg_integer(), Piece.color()) ::
          list(non_neg_integer())
  defp list_of_potential_moves(moves, starting_position, color) do
    case moves do
      [] ->
        [
          starting_position + 8 * direction_for(color),
          starting_position + 16 * direction_for(color)
        ]

      _ ->
        [starting_position + 8 * direction_for(color)]
    end
  end

  @spec direction_for(Piece.color()) :: -1 | 1
  defp direction_for(:white), do: -1
  defp direction_for(_), do: 1
end
