defmodule Chess.Pieces.Rook do
  @moduledoc """
  Represents a Rook piece.
  """
  use Nebulex.Caching

  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Piece

  @impl Piece
  def potential_moves(piece, starting_index, board) do
    starting_index
    |> list_of_potential_moves()
    |> filter_unreachable_coordinates(piece, board)
    |> Stream.map(&Board.coordinates_to_index/1)
    |> MapSet.new()
  end

  @decorate cacheable(cache: Chess.Pieces.MoveCache, key: {__MODULE__, starting_index})
  @spec list_of_potential_moves(Board.index()) ::
          list({list(Board.coordinates()), list(Board.coordinates())})
  defp list_of_potential_moves(starting_index) do
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

    [{left, right}, {below, above}]
  end

  @spec filter_unreachable_coordinates(
          list({list(Board.coordinates()), list(Board.coordinates())}),
          Piece.t(),
          Board.t()
        ) :: Enumerable.t()
  defp filter_unreachable_coordinates(moves, piece, board) do
    moves
    |> Stream.map(fn {lower, higher} ->
      Enum.concat(
        reduce_until_blocked_or_capture(lower, piece, board),
        reduce_until_blocked_or_capture(higher, piece, board)
      )
    end)
    |> Stream.concat()
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
