defmodule Chess.Pieces.Knight do
  @moduledoc """
  Represents a Knight piece.
  """
  @behaviour Chess.Piece

  alias Chess.Piece
  alias Chess.Board
  alias Chess.Board.Square

  @impl Piece
  def potential_moves(_knight, starting_position, board) do
    starting_position
    |> list_of_potential_moves()
    |> Stream.filter(&Board.in_bounds?/1)
    |> Stream.reject(&Square.occupied?(board[&1]))
    |> MapSet.new()
  end

  @spec list_of_potential_moves(Board.index()) :: list(Board.index())
  defp list_of_potential_moves(starting_index) do
    [
      starting_index + 8 * 2 + 1,
      starting_index + 8 * 2 - 1,
      starting_index - 8 * 2 + 1,
      starting_index - 8 * 2 - 1,
      starting_index + 2 + 8,
      starting_index + 2 - 8,
      starting_index - 2 + 8,
      starting_index - 2 - 8
    ]
  end
end
