defmodule Chess.Boards.BitBoard do
  @moduledoc """
  A struct containing several bitboard representations
  of a chess game, which can be composed together to
  compute current game state and possible moves.

  This module uses the `:atomics` module for efficient
  concurrent access into an array of 64-bit integers.
  https://www.erlang.org/doc/man/atomics.html
  """

  defstruct [:ref]

  @type t() :: %__MODULE__{ref: :atomics.atomics_ref()}

  @bitboard_count 1

  @spec new() :: t()
  def new do
    %__MODULE__{ref: :atomics.new(@bitboard_count, signed: false)}
  end
end
