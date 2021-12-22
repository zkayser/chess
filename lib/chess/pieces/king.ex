defmodule Chess.Pieces.King do
  @moduledoc """
  Represents a king piece.
  """
  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Piece

  @impl Piece
  def potential_moves(king, starting_index, board) do
    starting_index
    |> list_of_potential_moves()
    |> reject_capturable_indices(king, board)
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

  _docp = """
  This prevents a King from moving itself into check (and violating a rule of chess).
  """

  @spec reject_capturable_indices(Enumerable.t(), Piece.t(), Board.t()) :: Enumerable.t()
  defp reject_capturable_indices(stream, %Piece{color: king_color}, board) do
    capturable_index_set_reducer = fn
      index, %Piece{color: color} = piece, capturable_index_set when color != king_color ->
        MapSet.union(capturable_index_set, Piece.potential_moves(piece, index, board))

      _index, _same_color, capturable_index_set ->
        capturable_index_set
    end

    capturable_index_set =
      :array.sparse_foldl(capturable_index_set_reducer, MapSet.new(), board.grid)

    Stream.reject(stream, &MapSet.member?(capturable_index_set, &1))
  end
end
