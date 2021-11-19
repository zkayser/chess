defmodule Chess.Piece do
  @moduledoc """
  Representation of a chess piece and associated
  functions.
  """
  alias Chess.Pieces.{Bishop, King, Knight, Pawn, Queen, Rook}

  @type t() ::
          %__MODULE__{
            type: type(),
            color: color()
          }
          | nil
  @type type() :: Pawn.t() | Rook.t() | Knight.t() | Bishop.t() | Queen.t() | King.t()
  @opaque color() :: :white | :black
  @typep index :: non_neg_integer()

  defstruct [:type, :color]

  # Starting Positions
  @pawn_indices Enum.concat(8..15, 48..55)
  @rook_indices [0, 7, 56, 63]
  @knight_indices [1, 6, 57, 62]
  @bishop_indices [2, 5, 58, 61]
  @queen_indices [3, 59]
  @king_indices [4, 60]
  @empty_indices 16..47

  @doc """
  Given a starting index, returns the piece that is placed
  at that index.

  iex> Chess.Piece.for_starting_position(0)
  %Chess.Piece{type: %Chess.Pieces.Rook{}, color: :black}
  """
  @spec for_starting_position(index()) :: t()
  def for_starting_position(index) when index in @empty_indices, do: nil

  def for_starting_position(index) do
    %__MODULE__{
      type: type_at_starting_position(index),
      color: if(index in 0..15, do: :black, else: :white)
    }
  end

  @spec type_at_starting_position(index()) :: type()
  defp type_at_starting_position(index) do
    case index do
      i when i in @pawn_indices -> %Pawn{}
      i when i in @rook_indices -> %Rook{}
      i when i in @knight_indices -> %Knight{}
      i when i in @bishop_indices -> %Bishop{}
      i when i in @queen_indices -> %Queen{}
      i when i in @king_indices -> %King{}
    end
  end
end
