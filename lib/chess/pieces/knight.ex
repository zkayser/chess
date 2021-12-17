defmodule Chess.Pieces.Knight do
  @moduledoc """
  Represents a Knight piece.
  """
  use Nebulex.Caching

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

  @decorate cacheable(cache: Chess.Pieces.MoveCache)
  @spec list_of_potential_moves(Board.index()) :: Enumerable.t()
  defp list_of_potential_moves(starting_index) do
    {starting_column, starting_row} = Board.index_to_coordinates(starting_index)

    [
      {starting_column + 1, starting_row + 2},
      {starting_column + 1, starting_row - 2},
      {starting_column + 2, starting_row + 1},
      {starting_column + 2, starting_row - 1},
      {starting_column - 1, starting_row + 2},
      {starting_column - 1, starting_row - 2},
      {starting_column - 2, starting_row + 1},
      {starting_column - 2, starting_row - 1}
    ]
    |> Stream.reject(fn {column, row} ->
      min(column, row) < 1 || max(column, row) > 8
    end)
    |> Stream.map(&Board.coordinates_to_index/1)
  end
end
