defmodule Chess.Moves.Generators.Perpendiculars do
  @moduledoc """
  Exposes utility functions for generating sets of
  potential moves along a perpendicular.
  """
  use Nebulex.Caching

  alias Chess.Board
  alias Chess.Moves.Generator

  @type section() :: list(Board.coordinates())
  @type t() :: list(section())

  @behaviour Generator

  @decorate cacheable(cache: Chess.Pieces.MoveCache, key: {__MODULE__, starting_index})
  @impl Generator
  @spec generate(Board.index()) :: t()
  def generate(starting_index) do
    {starting_col, starting_row} = Board.index_to_coordinates(starting_index)

    {lateral, vertical} = {
      for(column <- Enum.reject(1..8, &(&1 == starting_col)), do: {column, starting_row}),
      for(row <- Enum.reject(1..8, &(&1 == starting_row)), do: {starting_col, row})
    }

    [{left, right}, {below, above}] = [
      Enum.split_with(lateral, fn {col, _row} -> col < starting_col end),
      Enum.split_with(vertical, fn {_col, row} -> row < starting_row end)
    ]

    left = Enum.sort_by(left, &elem(&1, 0), :desc)
    below = Enum.sort_by(below, &elem(&1, 1), :desc)

    [left, right, below, above]
  end
end
