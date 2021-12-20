defmodule Chess.Pieces.King do
  @moduledoc """
  Represents a king piece.
  """
  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Piece

  @impl Piece
  def potential_moves(_king, starting_index, _board) do
    starting_index
    |> list_of_potential_moves()
    |> MapSet.new()
  end

  @spec list_of_potential_moves(Board.index()) :: Enumerable.t()
  defp list_of_potential_moves(starting_index) do
    {starting_column, starting_row} = Board.index_to_coordinates(starting_index)

    [
      {starting_column + 1, starting_row},
      {starting_column - 1, starting_row},
      {starting_column, starting_row + 1},
      {starting_column, starting_row - 1},
      {starting_column + 1, starting_row + 1},
      {starting_column + 1, starting_row - 1},
      {starting_column - 1, starting_row + 1},
      {starting_column - 1, starting_row - 1}
    ]
    |> Stream.reject(fn {column, row} ->
      min(column, row) < 1 || max(column, row) > 8
    end)
    |> Stream.map(&Board.coordinates_to_index/1)
  end
end
