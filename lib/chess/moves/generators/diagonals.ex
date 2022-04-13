defmodule Chess.Moves.Generators.Diagonals do
  @moduledoc """
  Exposes utility functions for generating sets of
  potential moves along a diagonal.
  """
  alias Chess.Board
  alias Chess.Moves.Generator

  @behaviour Generator

  @operators ~w(- - + +)a

  @impl Generator
  def generate(starting_index) do
    {starting_col, starting_row} = Board.index_to_coordinates(starting_index)

    starting_col
    |> ranges()
    |> Enum.zip(@operators)
    |> Enum.map(fn {quadrant, operator} ->
      Enum.reduce_while(
        quadrant,
        {MapSet.new(), apply(Kernel, operator, [starting_row, 1])},
        &build_diagonal(&1, &2, operator)
      )
    end)
    |> Enum.map(fn
      {quadrant, _row} -> quadrant
      quadrant -> quadrant
    end)
  end

  @spec ranges(Board.index()) :: list(Board.index())
  def ranges(starting_column) do
    [(starting_column - 1)..1, (starting_column + 1)..8]
    |> List.duplicate(2)
    |> List.flatten()
  end

  @spec build_diagonal(integer(), {MapSet.t(Board.coordinates()), integer()}, :+ | :-) ::
          {:halt, MapSet.t(Board.coordinates())}
          | {:cont, {MapSet.t(Board.coordinates()), integer()}}
  defp build_diagonal(column, {coords, row}, operator) do
    case min(column, row) < 1 || max(column, row) > 8 do
      true ->
        {:halt, coords}

      false ->
        {:cont, {MapSet.put(coords, {column, row}), apply(Kernel, operator, [row, 1])}}
    end
  end
end
