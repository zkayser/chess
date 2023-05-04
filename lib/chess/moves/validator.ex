defmodule Chess.Moves.Validator do
  @moduledoc """
  Defines the interface for modules that can validate
  proposed moves.
  """
  alias Chess.Bitboards.Move
  alias Chess.Game
  alias Chess.Moves.Proposals

  @doc """
  Callback function for validating a proposed move.
  Piece modules should implement this callback for
  their own piece and the rules that govern what moves
  are or are not valid for that specific piece.
  """
  @callback validate_move(Game.t(), Proposals.t()) :: {:ok, Move.t()} | {:error, reason}
            when reason: any()
end
