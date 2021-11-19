defmodule Chess.Pieces.Bishop do
  @moduledoc """
  Represents a Bishop piece.
  """
  defstruct [
    moves: []
  ]

  @type t() :: %__MODULE__{
    moves: list()
  }
end
