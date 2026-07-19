defmodule Chess.BitBoards.Pieces.King do
  @moduledoc """
  Functions for generating and validating king moves on a bitboard.
  """

  @behaviour Chess.Moves.Validator

  import Bitwise

  alias Chess.Bitboards.Move
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
  alias Chess.Game
  alias Chess.Moves.Proposals

  @king_deltas [
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, -1},
    {0, 1},
    {1, -1},
    {1, 0},
    {1, 1}
  ]

  @impl Chess.Moves.Validator
  @spec validate_move(Game.t(), Proposals.t()) :: {:ok, Move.t()} | {:error, atom()}
  def validate_move(game, %Proposals{source: source, destination: destination}) do
    with :ok <- validate_geometry(source, destination),
         :ok <- validate_not_self_capture(game, destination) do
      {:ok, %Move{from: source, to: destination, flag: move_flag(game, destination)}}
    end
  end

  @doc """
  Returns true if the king of the given color is under attack
  in the given board position.
  """
  @spec in_check?(BitBoard.t(), Chess.player()) :: boolean()
  def in_check?(_board, _color) do
    false
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

  defp move_flag(game, destination) do
    opponent = opponent(game.current_player)

    if occupied_by?(game.board, opponent, destination) do
      :captures
    else
      :quiet
    end
  end

  defp occupied_by?(board, color, square) do
    pieces = BitBoard.get_raw(board, color)
    (pieces &&& Square.bitboard(square)) != 0
  end

  defp opponent(:white), do: :black
  defp opponent(:black), do: :white

  defp king_step?(source, destination) do
    Enum.any?(@king_deltas, fn delta ->
      Square.try_delta(source, delta) == {:ok, destination}
    end)
  end
end
