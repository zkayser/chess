defmodule Chess.Boards.BitBoard do
  @moduledoc """
  A struct containing several bitboard representations
  of a chess game, which can be composed together to
  compute current game state and possible moves.

  This module uses the `:atomics` module for efficient
  concurrent access into an array of 64-bit integers.
  https://www.erlang.org/doc/man/atomics.html
  """
  use Bitwise

  defstruct [:ref]

  @opaque bitboards() :: :atomics.atomics_ref()
  @type position() :: non_neg_integer()
  @type t() :: %__MODULE__{ref: bitboards()}
  @type bitboard() :: :positions

  @positions_index 1
  @bitboards %{positions: @positions_index}
  @bitboard_count 1

  @spec new() :: t()
  def new do
    bitboards = :atomics.new(@bitboard_count, signed: false)

    _ = initialize_positions(bitboards)

    %__MODULE__{ref: bitboards}
  end

  @spec to_list(t(), bitboard()) :: list()
  def to_list(bitboard, bitboard_type \\ :positions) do
    bitboard.ref
    |> :atomics.get(@bitboards[bitboard_type])
    |> Integer.digits(2)
    |> Enum.chunk_every(8)
  end

  @spec initialize_positions(bitboards()) :: list(:ok)
  defp initialize_positions(bitboards) do
    for shift <- Enum.concat(0..15, 48..63) do
      1
      |> bsl(shift)
      |> bor(:atomics.get(bitboards, @positions_index))
      |> then(fn bitboard -> :atomics.put(bitboards, @positions_index, bitboard) end)
    end
  end
end
