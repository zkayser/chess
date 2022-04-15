defmodule Chess.Moves.Filters do
  @moduledoc """
  Exposes filtering functions to reduce the set of
  possible moves and eliminate impossible or invalid
  moves from a set.
  """
  alias Chess.Board
  alias Chess.Moves.Generators.Diagonals
  alias Chess.Moves.Generators.Perpendiculars
  alias Chess.Piece

  @typep input() :: Diagonals.t() | Perpendiculars.t()

  @spec unreachable_coordinates(input(), Piece.t(), Board.t()) :: Enumerable.t()
  def unreachable_coordinates(inputs, piece, board) do
    Stream.flat_map(inputs, &reduce_until_blocked_or_capture(&1, piece, board))
  end

  @spec reduce_until_blocked_or_capture(
          Perpendiculars.section() | Diagonals.quadrant(),
          Piece.t(),
          Board.t()
        ) ::
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
