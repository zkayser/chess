defmodule Chess.Pieces.Bishop do
  @moduledoc """
  Represents a Bishop piece.
  """
  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Moves.Generators.Diagonals
  alias Chess.Piece

  @typep coordinate_set :: MapSet.t(Board.coordinates())
  @typep quadrants :: list(coordinate_set())

  @impl Piece
  def potential_moves(piece, starting_index, board) do
    starting_index
    |> Diagonals.generate()
    |> filter_unreachable_coordinates(piece, board)
    |> Stream.map(&Board.coordinates_to_index/1)
    |> MapSet.new()
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
