defmodule Chess.Pieces.Knight do
  @moduledoc """
  Represents a Knight piece.
  """

  defstruct [
    moves: []
  ]

  @type t() :: %__MODULE__{
    moves: list()
  }
end
