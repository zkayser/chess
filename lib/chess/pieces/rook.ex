defmodule Chess.Pieces.Rook do
  @moduledoc """
  Represents a Rook piece.
  """
  use Nebulex.Caching

  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Moves.Generators.Perpendiculars
  alias Chess.Piece

  @impl Piece
  def potential_moves(piece, starting_index, board) do
    starting_index
    |> Perpendiculars.generate()
    |> filter_unreachable_coordinates(piece, board)
    |> Stream.map(&Board.coordinates_to_index/1)
    |> MapSet.new()
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
