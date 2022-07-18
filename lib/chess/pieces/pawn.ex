defmodule Chess.Pieces.Pawn do
  @moduledoc """
  Represents a Pawn piece.
  """
  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Board.Square
  alias Chess.Piece

  @impl Piece
  def potential_moves(%Piece{color: color, moves: moves}, starting_position, board) do
    moves
    |> list_of_potential_moves(starting_position, color)
    |> Stream.filter(&Board.in_bounds?/1)
    |> Stream.reject(&invalid_capture?(&1, starting_position, color, board))
    |> Stream.reject(&occupied_non_capture?(&1, starting_position, board))
    |> MapSet.new()
  end

  @spec list_of_potential_moves(list(Board.index()), Board.index(), Piece.color()) ::
          list(Board.index())
  defp list_of_potential_moves(moves, starting_position, color) do
    case Enum.empty?(moves) do
      true ->
        [
          starting_position + 8 * direction_for(color),
          starting_position + 1 + 8 * direction_for(color),
          starting_position - 1 + 8 * direction_for(color),
          starting_position + 16 * direction_for(color)
        ]

      false ->
        [
          starting_position + 8 * direction_for(color),
          starting_position + 1 + 8 * direction_for(color),
          starting_position - 1 + 8 * direction_for(color)
        ]
    end
  end

  @spec direction_for(Piece.color()) :: -1 | 1
  defp direction_for(:white), do: -1
  defp direction_for(_), do: 1

  @spec invalid_capture?(Board.index(), Board.index(), Piece.color(), Board.t()) :: boolean()
  defp invalid_capture?(target, starting_point, color, board) do
    case rem(abs(target - starting_point), 8) do
      0 ->
        false

      _ ->
        should_drop_diagonal?(target, color, board)
    end
  end

  @spec should_drop_diagonal?(Board.index(), Piece.color(), Board.t()) :: boolean()
  defp should_drop_diagonal?(target, color, board) do
    case board[target] do
      %Piece{color: target_color} when target_color != color ->
        false

      _ ->
        true
    end
  end

  @spec occupied_non_capture?(Board.index(), Board.index(), Board.t()) :: boolean()
  defp occupied_non_capture?(target, starting_position, board) do
    case rem(abs(target - starting_position), 8) do
      0 ->
        Square.occupied?(board[target])

      _ ->
        false
    end
  end
end
