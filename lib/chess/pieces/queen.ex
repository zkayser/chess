defmodule Chess.Pieces.Queen do
  @moduledoc """
  Represents a Queen piece
  """
  alias Chess.Board
  alias Chess.Moves.Filters
  alias Chess.Moves.Generators.{Diagonals, Perpendiculars}
  alias Chess.Piece

  @behaviour Piece

  @impl Piece
  def potential_moves(queen, starting_index, board) do
    [Diagonals, Perpendiculars]
    |> Enum.map(fn generator ->
      fetch_task(generator, starting_index, queen, board)
    end)
    |> Task.await_many()
    |> Enum.flat_map(&Enum.to_list/1)
    |> MapSet.new()
  end

  @spec fetch_task(Diagonals | Perpendiculars, Board.index(), Piece.t(), Board.t()) :: Task.t()
  defp fetch_task(generator, starting_index, queen, board) do
    Task.async(fn ->
      starting_index
      |> generator.generate()
      |> Filters.unreachable_coordinates(queen, board)
    end)
  end
end
