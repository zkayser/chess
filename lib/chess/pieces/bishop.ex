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

    first_quadrant =
      Enum.reduce_while((starting_col - 1)..1, {MapSet.new(), starting_row - 1}, fn column,
                                                                                    {coords, row} ->
        case min(column, row) < 1 do
          true -> {:halt, coords}
          false -> {:cont, {MapSet.put(coords, {column, row}), row - 1}}
        end
      end)

    second_quadrant =
      Enum.reduce_while((starting_col + 1)..8, {MapSet.new(), starting_row - 1}, fn column,
                                                                                    {coords, row} ->
        case min(column, row) < 1 || max(column, row) > 8 do
          true -> {:halt, coords}
          false -> {:cont, {MapSet.put(coords, {column, row}), row - 1}}
        end
      end)

    third_quadrant =
      Enum.reduce_while((starting_col - 1)..1, {MapSet.new(), starting_row + 1}, fn column,
                                                                                    {coords, row} ->
        case min(column, row) < 1 || max(column, row) > 8 do
          true -> {:halt, coords}
          false -> {:cont, {MapSet.put(coords, {column, row}), row + 1}}
        end
      end)

    fourth_quadrant =
      Enum.reduce_while((starting_col + 1)..8, {MapSet.new(), starting_row + 1}, fn column,
                                                                                    {coords, row} ->
        case min(column, row) < 1 || max(column, row) > 8 do
          true -> {:halt, coords}
          false -> {:cont, {MapSet.put(coords, {column, row}), row + 1}}
        end
      end)

    [
      {first_quadrant, :asc},
      {second_quadrant, :desc},
      {third_quadrant, :asc},
      {fourth_quadrant, :desc}
    ]
    |> Enum.map(fn
      {{quadrant, _row}, sort_order} -> Enum.sort(quadrant, sort_order)
      {quadrant, sort_order} -> Enum.sort(quadrant, sort_order)
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
