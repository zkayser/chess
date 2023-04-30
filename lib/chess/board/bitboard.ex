defmodule Chess.Boards.BitBoard do
  @moduledoc """
  A struct containing several bitboard representations
  of a chess game, which can be composed together to
  compute current game state and possible moves.

  This module uses a series of 8-byte binaries to
  represent the state of a bitboard.
  """
  import Bitwise

  alias Chess.Color

  @full_row 0b11111111
  @rooks 0b10000001
  @knights 0b01000010
  @bishops 0b00100100
  @queen 0b00010000
  @king 0b00001000

  defstruct white: %{
              pawns: <<0, 0, 0, 0, 0, 0, @full_row, 0>>,
              rooks: <<0, 0, 0, 0, 0, 0, 0, @rooks>>,
              knights: <<0, 0, 0, 0, 0, 0, 0, @knights>>,
              bishops: <<0, 0, 0, 0, 0, 0, 0, @bishops>>,
              queens: <<0, 0, 0, 0, 0, 0, 0, @queen>>,
              king: <<0, 0, 0, 0, 0, 0, 0, @king>>
            },
            black: %{
              pawns: <<0, @full_row, 0, 0, 0, 0, 0, 0>>,
              rooks: <<@rooks, 0, 0, 0, 0, 0, 0, 0>>,
              knights: <<@knights, 0, 0, 0, 0, 0, 0, 0>>,
              bishops: <<@bishops, 0, 0, 0, 0, 0, 0, 0>>,
              queens: <<@queen, 0, 0, 0, 0, 0, 0, 0>>,
              king: <<@king, 0, 0, 0, 0, 0, 0, 0>>
            }

  @typedoc """
  A t:bitboard/0 is a 64-bit bitstring
  representation of one component (or composite) of
  an entire chess game bitboard representation.
  """
  @type bitboard() :: binary()

  @typep composites() :: :full | :white | :black

  @typep piece_keys() :: :pawns | :rooks | :knights | :bishops | :queens | :king

  @typep piece_positions() :: %{
           pawns: bitboard(),
           rooks: bitboard(),
           knights: bitboard(),
           bishops: bitboard(),
           queens: bitboard(),
           king: bitboard()
         }

  @type t() :: %__MODULE__{
          white: piece_positions(),
          black: piece_positions()
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
  Returns the list of all different bitboard types that are
  stored in a `#{__MODULE__}.t()` representation.
  """
  @spec accessors() :: list(bitboard_type())
  def accessors do
    for color <- ~w(white black)a, pieces <- ~w(pawns rooks knights bishops queens king)a do
      {color, pieces}
    end
    |> Enum.concat(~w(full white black)a)
  end

  @doc """
  Returns the specific bitboard denoted by `bitboard_type`
  stored within the `BitBoard.t/0` struct.
  """
  @spec get(t(), {Color.t(), piece_keys()} | composites()) :: bitboard()
  def get(bitboard, {color, pieces}) do
    bitboard
    |> Map.from_struct()
    |> get_in([color, pieces])
  end

  def get(bitboard, composite_type) do
    boards =
      case composite_type do
        :full -> bitboard.black |> Enum.concat(bitboard.white) |> Keyword.values()
        color -> bitboard |> Map.get(color) |> Map.values()
      end

    boards
    |> Enum.reduce(0, fn <<board::integer-size(64)>>, composite ->
      board ||| composite
    end)
    |> from_integer()
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
  Takes in an integer value and encodes it as a bitstring
  representation of a bitboard.
  """
  @spec from_integer(integer()) :: bitboard()
  def from_integer(bitboard), do: <<bitboard::integer-size(64)>>

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
