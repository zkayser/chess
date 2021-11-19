defmodule Chess.Pieces.Rook do
  @moduledoc """
  Represents a Rook piece.
  """

  defstruct [
    moves: []
  ]

  @type t() :: %__MODULE__{
    moves: list()
  }
end
