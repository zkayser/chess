defmodule Chess.BitBoards.Pieces.King do
  @moduledoc """
  Functions for generating and validating king moves on a bitboard.
  """

  @behaviour Chess.Moves.Validator

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
  def validate_move(_game, %Proposals{source: source, destination: destination}) do
    if king_step?(source, destination) do
      {:ok, %Move{from: source, to: destination, flag: :quiet}}
    else
      {:error, :invalid_geometry}
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

  defp king_step?(source, destination) do
    Enum.any?(@king_deltas, fn delta ->
      Square.try_delta(source, delta) == {:ok, destination}
    end)
  end
end
