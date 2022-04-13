defmodule Chess.Moves.Generator do
  @moduledoc """
  Module defining the Behaviour for move
  generators.
  """
  alias Chess.Board

  @doc """
  Callback that takes a starting index and
  returns an `Enumerable.t()` of a set of
  potential moves based on the starting index.
  """
  @callback generate(Board.index()) :: Enumerable.t()
end
