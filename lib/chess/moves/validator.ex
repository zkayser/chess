defmodule Chess.Moves.Validator do
  @moduledoc """
  Defines the interface for modules that can validate proposed moves.

  Implementations receive a `Chess.Moves.Proposals.t()` with human-readable
  `{file, rank}` coordinates. Convert once via `Proposals.masks/1` at the
  start of `validate_move/2`, run occupancy / attack / simulation checks on
  those masks, and build the returned `%Chess.Bitboards.Move{}` with the
  original tuples (plus an explicit flag or the destination mask for
  `Move.make/4`).
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
