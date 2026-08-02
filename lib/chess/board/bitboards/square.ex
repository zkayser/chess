defmodule Chess.Boards.Bitboards.Square do
  @moduledoc """
  Conveniences for working with bitboard representations of
  squares on the Chess board.

  ## Representations

  Squares appear in two complementary forms:

  * **Coordinate tuples** (`t:t/0`, e.g. `{"e", 1}`) — human-legible. Prefer
    these in tests, documentation examples, and at the user-input boundary
    (`Chess.Moves.Proposals`). Convert once at the edge of engine work.
  * **Square indices** (`t:index/0`, `0..63`) and **single-bit masks**
    (`t:mask/0`, `1 <<< index`) — the forms used on move/attack hot paths.
    Bit 0 is h1, bit 7 is a1, bit 8 is h2, …, bit 63 is a8.

  Use `to_index/1` / `from_index/1` and `mask/1` / `mask_from_index/1` to
  convert; avoid re-deriving masks from tuples inside loops or validators.
  """
  import Bitwise

  alias Chess.Bitboards.Slider
  alias Chess.Board.Coordinates

  @type t() :: Coordinates.t()

  @typedoc """
  Zero-based square index into a 64-bit bitboard. Bit 0 is h1; bit 63 is a8.
  """
  @type index() :: 0..63

  @typedoc """
  A 64-bit integer with (typically) a single bit set, identifying one square.
  """
  @type mask() :: integer()

  # File letters ordered by bit index within a rank (bit 0 = h, bit 7 = a).
  @files List.to_tuple(~w(h g f e d c b a))

  @doc """
  Attempts to apply a file and rank delta to a square.
  If the delta is a valid square on the board, returns
  `{:ok, new_square}`, otherwise returs `:error`.
  """
  @spec try_delta(t(), {file_delta, rank_delta}) :: {:ok, t()} | :error
        when file_delta: Slider.delta(), rank_delta: Slider.delta()
  def try_delta({<<file>>, rank}, {file_delta, rank_delta}) do
    case {<<file + file_delta>>, rank + rank_delta} do
      {<<new_file>>, new_rank} when new_file in ?a..?h and new_rank in 1..8 ->
        {:ok, {<<new_file>>, new_rank}}

      _ ->
        :error
    end
  end

  @doc """
  Converts a `{file, rank}` coordinate to a square index (`0..63`).

  Prefer calling this once at an API boundary, then using the index or a
  `mask_from_index/1` result on the hot path.
  """
  @spec to_index(t()) :: index()
  def to_index({file, rank}) do
    Coordinates.file_bit_index(file) + (rank - 1) * 8
  end

  @doc """
  Converts a square index (`0..63`) back to a `{file, rank}` coordinate.
  """
  @spec from_index(index()) :: t()
  def from_index(index) when index in 0..63 do
    {elem(@files, rem(index, 8)), div(index, 8) + 1}
  end

  @doc """
  Returns the single-bit mask for a square index (`1 <<< index`).
  """
  @spec mask_from_index(index()) :: mask()
  def mask_from_index(index) when index in 0..63, do: 1 <<< index

  @doc """
  Returns the single-bit mask for a `{file, rank}` coordinate.

  Equivalent to `bitboard/1`; prefer this name on new hot-path call sites.
  For repeated use, convert with `to_index/1` once and call `mask_from_index/1`.
  """
  @spec mask(t()) :: mask()
  def mask(square), do: mask_from_index(to_index(square))

  @doc """
  Returns the 64-bit bitboard representation of the square;
  that is, a 64-bit integer with a single bit set at the index
  representing the square.

  See also `mask/1` (alias) and `mask_from_index/1`.
  """
  @spec bitboard(t()) :: mask()
  def bitboard(square), do: mask(square)

  @doc """
  Converts a single-bit bitboard integer to a square coordinate.

  Returns `nil` when no bits are set. When multiple bits are set, returns
  the square corresponding to the least-significant set bit.
  """
  @spec from_bitboard(integer()) :: t() | nil
  def from_bitboard(0), do: nil

  def from_bitboard(bits) when is_integer(bits) and bits > 0 do
    from_index(trailing_zeros(bits))
  end

  defp trailing_zeros(n), do: trailing_zeros(n, 0)
  defp trailing_zeros(n, index) when (n &&& 1) == 1, do: index
  defp trailing_zeros(n, index), do: trailing_zeros(n >>> 1, index + 1)
end
