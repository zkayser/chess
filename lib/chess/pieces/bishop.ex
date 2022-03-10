defmodule Chess.Pieces.Bishop do
  @moduledoc """
  Represents a Bishop piece.
  """

  use Nebulex.Caching

  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Piece

  @typep coordinate_set :: MapSet.t(Board.coordinates())
  @typep quadrants :: list(coordinate_set())

  @impl Piece
  def potential_moves(piece, starting_index, board) do
    starting_index
    |> list_of_potential_moves()
    |> filter_unreachable_coordinates(piece, board)
    |> Stream.map(&Board.coordinates_to_index/1)
    |> MapSet.new()
  end

  @decorate cacheable(cache: Chess.Pieces.MoveCache, key: {__MODULE__, starting_index})
  @spec list_of_potential_moves(Board.index()) :: quadrants()
  defp list_of_potential_moves(starting_index) do
    {starting_col, starting_row} = Board.index_to_coordinates(starting_index)

    ranges = [(starting_col - 1)..1, (starting_col + 1)..8] |> List.duplicate(2) |> List.flatten()
    operators = [:-, :-, :+, :+]

    ranges
    |> Enum.zip(operators)
    |> Enum.map(fn {quadrant, operator} ->
      Enum.reduce_while(
        quadrant,
        {MapSet.new(), apply(Kernel, operator, [starting_row, 1])},
        fn column, {coords, row} ->
          case min(column, row) < 1 || max(column, row) > 8 do
            true ->
              {:halt, coords}

            false ->
              {:cont, {MapSet.put(coords, {column, row}), apply(Kernel, operator, [row, 1])}}
          end
        end
      )
    end)
    |> Enum.map(fn
      {quadrant, _row} -> quadrant
      quadrant -> quadrant
    end)
  end

  @spec filter_unreachable_coordinates(
          quadrants(),
          Piece.t(),
          Board.t()
        ) :: Enumerable.t()
  defp filter_unreachable_coordinates(quadrants, piece, board) do
    Enum.flat_map(quadrants, &reduce_until_blocked_or_capture(&1, piece, board))
  end

  @spec reduce_until_blocked_or_capture(list(Board.coordinates()), Piece.t(), Board.t()) ::
          list(Board.coordinates())
  defp reduce_until_blocked_or_capture(potential_moves, %Piece{color: color}, board) do
    Enum.reduce_while(potential_moves, [], fn coords, moves ->
      case board[coords] do
        %Piece{color: target_color} when target_color != color -> {:halt, [coords | moves]}
        %Piece{color: target_color} when target_color == color -> {:halt, moves}
        nil -> {:cont, [coords | moves]}
      end
    end)
  end
end
