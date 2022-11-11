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

  @opaque bitboards() :: :atomics.atomics_ref()
  @type position() :: non_neg_integer()
  @type t() :: %__MODULE__{ref: bitboards()}
  @type bitboard() ::
          :composite
          | :white_pawns
          | :white_rooks
          | :white_knights
          | :white_bishops
          | :white_queens
          | :white_king
          | :black_pawns
          | :black_rooks
          | :black_knights
          | :black_bishops
          | :black_queens
          | :black_king

  @initial_boards [
    {:composite, 18_446_462_598_732_906_495},
    {:black_bishops, 2_594_073_385_365_405_696},
    {:black_king, 576_460_752_303_423_488},
    {:black_knights, 4_755_801_206_503_243_776},
    {:black_pawns, 71_776_119_061_217_280},
    {:black_queens, 1_152_921_504_606_846_976},
    {:black_rooks, 9_295_429_630_892_703_744},
    {:white_bishops, 36},
    {:white_king, 8},
    {:white_knights, 66},
    {:white_pawns, 65280},
    {:white_queens, 16},
    {:white_rooks, 129}
  ]

  @atomics_offset 1

  @bitboards @initial_boards
             |> Enum.with_index(@atomics_offset)
             |> Enum.map(fn {{key, _}, index} -> {key, index} end)

  @spec new() :: t()
  def new do
    bitboards = :atomics.new(length(@bitboards), signed: false)

    for {bitboard_type, bitboard_index} <- @bitboards do
      :atomics.put(bitboards, bitboard_index, @initial_boards[bitboard_type])
    end

    %__MODULE__{ref: bitboards}
  end

  @doc """
  Returns an 8x8 grid representation of a given
  bitboard. If the bitboard does not take up a full
  64 bits, the representation is padded with 0s to
  create a full 8x8 grid. This function is intended
  mainly for inspecting the state of a bitboard in
  a way that is human-readable at a glance.
  """
  @spec to_list(t(), bitboard()) :: list(list(0 | 1))
  def to_list(bitboard, bitboard_type \\ :composite) do
    bitboard.ref
    |> :atomics.get(@bitboards[bitboard_type])
    |> Integer.digits(2)
    |> then(&with_padding/1)
    |> Enum.chunk_every(8)
  end

  @spec with_padding(list(0 | 1)) :: list(0 | 1)
  defp with_padding(board) do
    board_length = Enum.count(board)

    zeros = fn _ -> 0 end

    case board_length < 64 do
      true -> Enum.concat(Enum.map(board_length..63, zeros), board)
      false -> board
    end
  end
end
