defmodule Chess.Pieces.Rook do
  @moduledoc """
  Represents a Rook piece.
  """
  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Piece

  @impl Piece
  def potential_moves(_piece, starting_index, _board) do
    starting_index
    |> list_of_potential_moves()
    |> MapSet.new()
  end

  @spec list_of_potential_moves(Board.index()) :: MapSet.t(Board.index())
  defp list_of_potential_moves(starting_index) do
    {starting_col, starting_row} = Board.index_to_coordinates(starting_index)

    lateral_moves =
      for column <- Enum.reject(1..8, &(&1 == starting_col)), do: {column, starting_row}

    vertical_moves = for row <- Enum.reject(1..8, &(&1 == starting_row)), do: {starting_col, row}

    lateral_moves
    |> Stream.concat(vertical_moves)
    |> Stream.map(&Board.coordinates_to_index/1)
  end
end
