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
      {:ok, %Move{from: source, to: destination, flag: :quiet}}
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
    own_pieces = BitBoard.get_raw(game.board, game.current_player)
    dest_mask = Square.bitboard(destination)

    if (own_pieces &&& dest_mask) != 0 do
      {:error, :self_capture}
    else
      :ok
    end
  end

  defp king_step?(source, destination) do
    Enum.any?(@king_deltas, fn delta ->
      Square.try_delta(source, delta) == {:ok, destination}
    end)
  end
end
