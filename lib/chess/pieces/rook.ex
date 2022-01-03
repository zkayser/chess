defmodule Chess.Pieces.Rook do
  @moduledoc """
  Represents a Rook piece.
  """
  @behaviour Chess.Piece

  alias Chess.Board
  alias Chess.Piece

  @impl Piece
  def potential_moves(piece, starting_index, board) do
    starting_index
    |> list_of_potential_moves(piece, board)
    |> Stream.map(&Board.coordinates_to_index/1)
    |> MapSet.new()
  end

  @spec list_of_potential_moves(Board.index(), Piece.t(), Board.t()) :: Enumerable.t()
  defp list_of_potential_moves(starting_index, piece, board) do
    {starting_col, starting_row} = Board.index_to_coordinates(starting_index)

    lateral_moves =
      for column <- Enum.reject(1..8, &(&1 == starting_col)), do: {column, starting_row}

    {left, right} = Enum.split_with(lateral_moves, fn {col, _row} -> col < starting_col end)
    left = Enum.sort_by(left, &elem(&1, 0), :desc)

    lateral_moves =
      Enum.concat(
        reduce_until_blocked_or_capture(left, piece, board),
        reduce_until_blocked_or_capture(right, piece, board)
      )

    vertical_moves = for row <- Enum.reject(1..8, &(&1 == starting_row)), do: {starting_col, row}

    {below, above} = Enum.split_with(vertical_moves, fn {_col, row} -> row < starting_row end)
    below = Enum.sort_by(below, &elem(&1, 1), :desc)

    vertical_moves =
      Enum.concat(
        reduce_until_blocked_or_capture(below, piece, board),
        reduce_until_blocked_or_capture(above, piece, board)
      )

    Stream.concat(lateral_moves, vertical_moves)
  end

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
