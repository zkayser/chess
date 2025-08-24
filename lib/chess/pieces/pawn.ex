defmodule Chess.Pieces.Pawn do
  @moduledoc """
  Represents a Pawn piece.
  """
  @behaviour Chess.Piece

alias Chess.Board.Coordinates
  alias Chess.Boards.BitBoard
  alias Chess.Piece

  @impl Piece
  def potential_moves(%Piece{color: color, moves: moves}, starting_position, game) do
    board = game.board

    regular_moves =
      moves
      |> list_of_potential_moves(starting_position, color)
      |> Stream.filter(&(&1 in 0..63))
      |> Stream.reject(&invalid_capture?(&1, starting_position, color, board))
      |> Stream.reject(&occupied_non_capture?(&1, starting_position, board))
      |> MapSet.new()

    en_passant_move =
      case game.en_passant_target do
        nil ->
          MapSet.new()

        target ->
          pawn_rank = div(starting_position, 8)
          en_passant_rank = if color == :white, do: 3, else: 4

          if pawn_rank == en_passant_rank &&
               (abs(target - (starting_position + 8 * direction_for(color) + 1)) == 0 ||
                abs(target - (starting_position + 8 * direction_for(color) - 1)) == 0) do
            MapSet.new([target])
          else
            MapSet.new()
          end
      end

    MapSet.union(regular_moves, en_passant_move)
  end

  @spec list_of_potential_moves(MapSet.t(Board.index()), Board.index(), Piece.color()) ::
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

  @spec invalid_capture?(Board.index(), Board.index(), Piece.color(), BitBoard.t()) :: boolean()
  defp invalid_capture?(target, starting_point, color, board) do
    case rem(abs(target - starting_point), 8) do
      0 ->
        false

      _ ->
        should_drop_diagonal?(target, color, board)
    end
  end

  @spec should_drop_diagonal?(Board.index(), Piece.color(), BitBoard.t()) :: boolean()
  defp should_drop_diagonal?(target, color, board) do
    opponent_color = if color == :white, do: :black, else: :white
    opponent_board = BitBoard.get(board, opponent_color)
    !BitBoard.square_occupied?(opponent_board, Coordinates.index_to_coordinates(target))
  end

  @spec occupied_non_capture?(Board.index(), Board.index(), BitBoard.t()) :: boolean()
  defp occupied_non_capture?(target, starting_position, board) do
    case rem(abs(target - starting_position), 8) do
      0 ->
        full_board = BitBoard.get(board, :full)
        BitBoard.square_occupied?(full_board, Coordinates.index_to_coordinates(target))

      _ ->
        false
    end
  end
end
