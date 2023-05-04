defmodule Chess.Pieces do
  @moduledoc """
  Functions and types for defining and working with
  the different type of chess pieces.
  """
  alias Chess.BitBoards.Pieces.{Bishop, King, Knight, Pawn, Queen, Rook}
  alias Chess.Game
  alias Chess.Moves.Proposals

  @typedoc """
  Represents the individual piece modules themselves
  """
  @type piece() :: Bishop | King | Knight | Pawn | Queen | Rook

  @doc """
  Takes in a game and a source position (given as a `{file, rank}` tuple)
  and returns the piece module for the piece that is present at the given
  source position.

  If the source position is not occupied, returns an error tuple instead.
  """
  @spec classify(Game.t(), Proposals.coordinates()) :: {:ok, piece()} | {:error, :unoccupied}
  def classify(game, source) do
  end
end
