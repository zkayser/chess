defmodule Chess.Piece do
  @moduledoc """
  Representation of a chess piece and associated
  functions.
  """


  @type t() :: %__MODULE__{
    type: type(),
    color: color()
  } | nil
  @type type() :: :pawn | :rook | :knight | :bishop | :queen | :king
  @opaque color :: :white | :black

  defstruct [:type, :color]
end
