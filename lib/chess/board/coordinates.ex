defmodule Chess.Board.Coordinates do
  @moduledoc """
  Encapsulates the representation a the `file, rank` chess
  coordinate system, and exposes functions for converting back
  and forth between different representations.
  """
  import Bitwise

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
  @file_masks Map.new(Enum.with_index(~w(h g f e d c b a)))

  @doc """
  Takes a `__MODULE__.t()` coordinate (`{file, rank}`) and
  returns the coordinate as a bit representation.
  """
  @spec to_bitboard(t()) :: integer()
  def to_bitboard({file, rank}) do
    rank_shift = (rank - 1) * 8
    file_shift = @file_masks[file]
    1 <<< (file_shift + rank_shift)
  end
end
