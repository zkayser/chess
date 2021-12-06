defmodule Chess.Board.Square do
  @moduledoc """
  Representation of a square on a chess board.
  """
  use Oath

  import Integer, only: [is_even: 1]

  alias Chess.Piece

  @type t() :: %__MODULE__{
          color: color(),
          piece: Piece.t()
        }
  @type index :: non_neg_integer()
  @opaque color :: :white | :black

  defstruct color: nil,
            piece: nil

  @decorate pre("Index is a non-negative integer between 0 and 64", fn index -> index in 0..64 end)
  @spec init(non_neg_integer()) :: t()
  def init(index) do
    %__MODULE__{
      color: color_for(index),
      piece: Piece.for_starting_position(index)
    }
  end

  @spec occupiable?(t(), Piece.t()) :: boolean()
  def occupiable?(%__MODULE__{piece: %Piece{color: color}}, %Piece{color: color}), do: false

  def occupiable?(%__MODULE__{piece: %Piece{color: _color}}, %Piece{color: _other_color}),
    do: true

  def occupiable?(_, _), do: true

  @spec occupied?(t()) :: boolean()
  def occupied?(%__MODULE__{piece: %Piece{}}), do: true
  def occupied?(_), do: false

  @spec color_for(index()) :: color()
  defp color_for(index) when is_even(index), do: :white
  defp color_for(_index), do: :black
end
