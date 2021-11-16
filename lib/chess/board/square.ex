defmodule Chess.Board.Square do
  @moduledoc """
  Representation of a square on a chess board.
  """
  use Oath

  import Integer, only: [is_even: 1]

  alias Chess.Piece

  @type t() :: %__MODULE__{
    color: color(),
    piece: Piece.t() | :empty
  }
  @opaque color :: :white | :black
  @typep index :: non_neg_integer()

  defstruct [
    color: nil,
    piece: :empty
  ]

  @decorate pre("Index is a non-negative integer between 0 and 64", fn index -> index in 0..64 end)
  @spec init(non_neg_integer()) :: t()
  def init(index) do
    %__MODULE__{
      color: color_for(index),
      piece: piece_for(index)
    }
  end

  @spec color_for(index()) :: color()
  defp color_for(index) when is_even(index), do: :white
  defp color_for(_index), do: :black

  @pawn_indices Enum.concat(8..15, 48..55)
  @rook_indices [0, 7, 56, 63]
  @knight_indices [1, 6, 57, 62]
  @bishop_indices [2, 5, 58, 61]
  @queen_indices [3, 59]
  @king_indices [4, 60]
  @spec piece_for(index()) :: Piece.t() | :empty
  defp piece_for(index) when index in @pawn_indices, do: :pawn
  defp piece_for(index) when index in @rook_indices, do: :rook
  defp piece_for(index) when index in @knight_indices, do: :knight
  defp piece_for(index) when index in @bishop_indices, do: :bishop
  defp piece_for(index) when index in @queen_indices, do: :queen
  defp piece_for(index) when index in @king_indices, do: :king
  defp piece_for(_), do: :empty
end
