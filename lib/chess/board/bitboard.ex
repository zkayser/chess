defmodule Chess.Boards.BitBoard do
  @moduledoc """
  A struct containing several bitboard representations
  of a chess game, which can be composed together to
  compute current game state and possible moves.

  This module uses a series of 8-byte binaries to
  represent the state of a bitboard.
  """
  @full_row 0b11111111
  @rooks 0b10000001
  @knights 0b01000010
  @bishops 0b00100100
  @queen 0b00010000
  @king 0b00001000

  defstruct composite: <<@full_row, @full_row, 0, 0, 0, 0, @full_row, @full_row>>,
            white_pawns: <<0, 0, 0, 0, 0, 0, @full_row, 0>>,
            white_rooks: <<0, 0, 0, 0, 0, 0, 0, @rooks>>,
            white_knights: <<0, 0, 0, 0, 0, 0, 0, @knights>>,
            white_bishops: <<0, 0, 0, 0, 0, 0, 0, @bishops>>,
            white_queens: <<0, 0, 0, 0, 0, 0, 0, @queen>>,
            white_king: <<0, 0, 0, 0, 0, 0, 0, @king>>,
            black_pawns: <<0, @full_row, 0, 0, 0, 0, 0, 0>>,
            black_rooks: <<@rooks, 0, 0, 0, 0, 0, 0, 0>>,
            black_knights: <<@knights, 0, 0, 0, 0, 0, 0, 0>>,
            black_bishops: <<@bishops, 0, 0, 0, 0, 0, 0, 0>>,
            black_queens: <<@queen, 0, 0, 0, 0, 0, 0, 0>>,
            black_king: <<@king, 0, 0, 0, 0, 0, 0, 0>>,
            black_composite: <<@full_row, @full_row, 0, 0, 0, 0, 0, 0>>,
            white_composite: <<0, 0, 0, 0, 0, 0, @full_row, @full_row>>

  @typedoc """
  A t:bitboard/0 is specifically a 64-bit bitstring
  that represents one component or composite of
  an entire chess game bitboard representation.
  """
  @type bitboard() :: binary()
  @type position() :: non_neg_integer()
  @type t() :: %__MODULE__{
          composite: bitboard(),
          white_pawns: bitboard(),
          white_rooks: bitboard(),
          white_knights: bitboard(),
          white_queens: bitboard(),
          white_king: bitboard(),
          black_pawns: bitboard(),
          black_rooks: bitboard(),
          black_knights: bitboard(),
          black_bishops: bitboard(),
          black_queens: bitboard(),
          black_king: bitboard(),
          black_composite: bitboard(),
          white_composite: bitboard()
        }
  @type bitboard_type() ::
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
          | :black_composite
          | :white_composite

  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc """
  Returns the list off all different bitboard types that are
  stored in a Bitboard.t() representation.
  """
  @spec list_types() :: list(bitboard_type())
  def list_types do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
  end

  @doc """
  Returns the specific bitboard denoted by `bitboard_type`
  stored within the `BitBoard.t/0` struct.
  """
  @spec get(t(), bitboard_type()) :: bitboard()
  def get(bitboard, type) do
    Map.fetch!(bitboard, type)
  end

  @doc """
  Returns the integer-encoded value of the underlying
  bitstring for the bitboard.
  """
  @spec get_raw(t(), bitboard_type()) :: integer()
  def get_raw(bitboard, type) do
    <<value::integer-size(64)>> = get(bitboard, type)
    value
  end

  @doc """
  Returns an 8x8 grid representation of a given
  bitboard. If the bitboard does not take up a full
  64 bits, the representation is padded with 0s to
  create a full 8x8 grid. This function is intended
  mainly for debugging and inspecting the state of
  a bitboard in a way that is human-readable at a glance.
  """
  @spec to_grid(bitboard()) :: list(list(0 | 1))
  def to_grid(<<bitboard::integer-size(64)>>) do
    bitboard
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
