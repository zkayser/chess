defmodule Chess.Pieces.Queen do
  @moduledoc """
  Represents a Queen piece
  """

  defstruct [
    moves: []
  ]

  @type t() :: %__MODULE__{
    moves: list()
  }
end
