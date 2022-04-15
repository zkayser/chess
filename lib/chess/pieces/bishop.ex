defmodule Chess.Pieces.Bishop do
  @moduledoc """
  Represents a Bishop piece.
  """
  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Moves.Filters
  alias Chess.Moves.Generators.Diagonals
  alias Chess.Piece

  @impl Piece
  def potential_moves(piece, starting_index, board) do
    starting_index
    |> Diagonals.generate()
    |> Filters.unreachable_coordinates(piece, board)
    |> Stream.map(&Board.coordinates_to_index/1)
    |> MapSet.new()
  end
end
