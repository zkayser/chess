defmodule Chess.Moves.Generators.Diagonals do
  @moduledoc """
  Exposes utility functions for generating sets of
  potential moves along a diagonal.
  """
  use Nebulex.Caching

  alias Chess.Board
  alias Chess.Moves.Generator

  @behaviour Generator

  @operators ~w(- - + +)a

  @type quadrant() :: list(Board.coordinates())
  @type t() :: list(quadrant())

  @decorate cacheable(cache: Chess.Pieces.MoveCache, key: {__MODULE__, starting_index})
  @impl Generator
  @spec generate(Board.index()) :: t()
  def generate(starting_index) do
    {starting_col, starting_row} = Board.index_to_coordinates(starting_index)

    starting_col
    |> ranges()
    |> Enum.zip(@operators)
    |> Enum.map(fn {quadrant, operator} ->
      Enum.reduce_while(
        quadrant,
        {%{coords: [], sort: sort_for(operator)}, apply(Kernel, operator, [starting_row, 1])},
        &build_diagonal(&1, &2, operator)
      )
    end)
    |> Enum.map(fn
      {%{coords: quadrant, sort: sort}, _row} ->
        Enum.sort_by(quadrant, &Board.coordinates_to_index/1, sort)

      %{coords: quadrant, sort: sort} ->
        Enum.sort_by(quadrant, &Board.coordinates_to_index/1, sort)
    end)
  end

  @spec ranges(Board.index()) :: list(Board.index())
  def ranges(starting_column) do
    [(starting_column - 1)..1, (starting_column + 1)..8]
    |> List.duplicate(2)
    |> List.flatten()
  end

  @spec build_diagonal(
          integer(),
          {%{coords: list(Board.coordinates()), sort: :asc | :desc}, integer()},
          :+ | :-
        ) ::
          {:halt, %{coords: list(Board.coordinates()), sort: :desc | :asc}}
          | {:cont, {%{coords: list(Board.coordinates()), sort: :desc | :asc}, integer()}}
  defp build_diagonal(column, {%{coords: coords} = acc, row}, operator) do
    case min(column, row) < 1 || max(column, row) > 8 do
      true ->
        {:halt, acc}

      false ->
        {:cont,
         {Map.put(acc, :coords, [{column, row} | coords]), apply(Kernel, operator, [row, 1])}}
    end
  end

  @spec sort_for(:- | :+) :: :desc | :asc
  defp sort_for(:-), do: :desc
  defp sort_for(:+), do: :asc
end
