defmodule Chess.Pieces.Pawn do
  @moduledoc """
  Represents a Pawn piece.
  """

  defstruct [
    moves: []
  ]

  @type t() :: %__MODULE__{
    moves: list()
  }
end
