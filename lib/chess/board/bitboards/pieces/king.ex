defmodule Chess.BitBoards.Pieces.King do
  @moduledoc """
  King move validation (`Chess.Moves.Validator`).

  Orchestrates geometry, self-capture, and king-safety checks. Attack
  detection lives in `Chess.Bitboards.Attacks`; candidate-move simulation
  lives on `Chess.Boards.BitBoard`. Castling is reserved for a follow-up.
  """

  @behaviour Chess.Moves.Validator

  alias Chess.Bitboards.Attacks
  alias Chess.Bitboards.Move
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
  alias Chess.Game
  alias Chess.Moves.Proposals

  @impl Chess.Moves.Validator
  @spec validate_move(Game.t(), Proposals.t()) :: {:ok, Move.t()} | {:error, atom()}
  def validate_move(game, %Proposals{source: source, destination: destination}) do
    with :ok <- validate_geometry(source, destination),
         :ok <- validate_not_self_capture(game, destination),
         :ok <- validate_king_safety(game, source, destination) do
      flag = Move.quiet_or_capture(game.board, game.current_player, destination)
      {:ok, %Move{from: source, to: destination, flag: flag}}
    end
  end

  @doc """
  Returns true if the king of the given color is under attack
  in the given board position.
  """
  @spec in_check?(BitBoard.t(), Chess.player()) :: boolean()
  def in_check?(board, color) do
    case king_square(board, color) do
      nil -> false
      square -> Attacks.square_attacked_by?(board, opponent(color), square)
    end
  end

  defp validate_geometry(source, destination) do
    if king_step?(source, destination) do
      :ok
    else
      {:error, :invalid_geometry}
    end
  end

  defp validate_not_self_capture(game, destination) do
    if occupied_by?(game.board, game.current_player, destination) do
      {:error, :self_capture}
    else
      :ok
    end
  end

  defp validate_king_safety(game, source, destination) do
    board_after_move =
      BitBoard.apply_candidate_move(
        game.board,
        game.current_player,
        :king,
        source,
        destination
      )

    if in_check?(board_after_move, game.current_player) do
      {:error, :king_in_check}
    else
      :ok
    end
  end

  defp king_square(board, color) do
    board
    |> BitBoard.get_raw({color, :king})
    |> Square.from_bitboard()
  end

  defp occupied_by?(board, color, square) do
    board
    |> BitBoard.get(color)
    |> BitBoard.square_occupied?(square)
  end

  defp opponent(:white), do: :black
  defp opponent(:black), do: :white

  defp king_step?({<<from_file>>, from_rank}, {<<to_file>>, to_rank}) do
    file_delta = abs(to_file - from_file)
    rank_delta = abs(to_rank - from_rank)

    file_delta <= 1 and rank_delta <= 1 and {file_delta, rank_delta} != {0, 0}
  end
end
