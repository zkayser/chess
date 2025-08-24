defmodule Chess.Board.Coordinates do
  @moduledoc """
  Encapsulates the representation a the `file, rank` chess
  coordinate system, and exposes functions for converting back
  and forth between different representations.
  """

  @typedoc """
  A `t:file/0` is a 1-byte (8-bit) string,
  and specifically should contain only the
  characters `a` through `h` to represent the
  eight files on a chess board.
  """
  @type file() :: <<_::8>>

  @typedoc """
  A rank (the rows) on a chess board are
  represented by the integers 1 to 8.
  """
  @type rank() :: 1..8
  @type t() :: {file(), rank()}

  # This allows us to go from right to left with files, as is standard
  # in chess representations, but keep the bit indexes in the order
  # we'll find them in the binary bitboard representations, which is
  # going to be from 0 to 7, going from right to left across the file
  # from file h to file a.
  # This is used to create a bit mask that allows us to determine if
  # a position is occupied on the bitboard, and by which piece type.
  @bit_indices Map.new(Enum.with_index(~w(h g f e d c b a)))

  @doc """
  Returns the bit index for the given file within
  an 8-bit binary.
  """
  @spec file_bit_index(file()) :: 0..7
  def file_bit_index(file), do: @bit_indices[file]

  @files ~w(h g f e d c b a)

  @doc """
  Converts a board index (0-63) to a `{file, rank}` tuple.
  """
  @spec index_to_coordinates(0..63) :: t()
  def index_to_coordinates(index) do
    rank = 8 - div(index, 8)
    file_index = rem(index, 8)
    file = Enum.at(@files, file_index)
    {file, rank}
  end
end
