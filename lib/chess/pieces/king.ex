defmodule Chess.Pieces.King do
  @moduledoc """
  Represents a king piece.
  """

  defstruct [
    moves: []
  ]

  @type t() :: %__MODULE__{
    moves: list()
  }
end
