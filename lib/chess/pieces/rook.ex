defmodule Chess.Pieces.Rook do
  @moduledoc """
  Represents a Rook piece.
  """
  use Nebulex.Caching

  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Moves.Filters
  alias Chess.Moves.Generators.Perpendiculars
  alias Chess.Piece

  @impl Piece
  def potential_moves(piece, starting_index, board) do
    starting_index
    |> Perpendiculars.generate()
    |> Filters.unreachable_coordinates(piece, board)
    |> Stream.map(&Board.coordinates_to_index/1)
    |> MapSet.new()
  end
end
