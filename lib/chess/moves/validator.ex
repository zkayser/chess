defmodule Chess.Moves.Validator do
  @moduledoc """
  Defines the interface for modules that can validate
  proposed moves.

  Implementations receive a `Chess.Moves.Proposals.t()` whose
  `source_mask` / `destination_mask` (and indices) were computed
  once at the proposal boundary. Prefer those fields over
  re-deriving masks from `source` / `destination` tuples.
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
