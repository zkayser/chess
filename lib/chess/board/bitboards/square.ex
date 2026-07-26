defmodule Chess.Boards.Bitboards.Square do
  @moduledoc """
  Conveniences for working with bitboard representations of
  squares on the Chess board.
  """
  import Bitwise

  alias Chess.Bitboards.Slider
  alias Chess.Board.Coordinates

  @type t() :: Coordinates.t()

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
  Returns the 64-bit bitboard representation of the square;
  that is, a 64-bit binary with a single bit set at the index
  representing the square.
  """
  @spec bitboard(t()) :: integer()
  def bitboard({file, rank}) do
    file_index = Coordinates.file_bit_index(file)
    rank_offset = (rank - 1) * 8

    1 <<< (rank_offset + file_index)
  end

  @doc """
  Converts a single-bit bitboard integer to a square coordinate.

  Returns `nil` when no bits are set. When multiple bits are set, returns
  the square corresponding to the least-significant set bit.
  """
  @spec from_bitboard(integer()) :: t() | nil
  def from_bitboard(0), do: nil

  def from_bitboard(bits) when is_integer(bits) and bits > 0 do
    bit_index = trailing_zeros(bits)
    rank = div(bit_index, 8) + 1
    file = Enum.at(~w(h g f e d c b a), rem(bit_index, 8))
    {file, rank}
  end

  defp trailing_zeros(n), do: trailing_zeros(n, 0)
  defp trailing_zeros(n, index) when (n &&& 1) == 1, do: index
  defp trailing_zeros(n, index), do: trailing_zeros(n >>> 1, index + 1)
end
