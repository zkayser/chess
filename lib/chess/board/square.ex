defmodule Chess.Board.Square do
  @moduledoc """
  Representation of a square on a chess board.
  """
  alias Chess.Piece

  @type t() :: %__MODULE__{
          color: color(),
          piece: Piece.t()
        }
  @type index :: non_neg_integer()
  @opaque color :: :white | :black

  defstruct color: nil,
            piece: nil

  @spec occupiable?(t(), Piece.t()) :: boolean()
  def occupiable?(%__MODULE__{piece: %Piece{color: color}}, %Piece{color: color}), do: false

  def occupiable?(%__MODULE__{piece: %Piece{color: _color}}, %Piece{color: _other_color}),
    do: true

  def occupiable?(_, _), do: true

  @spec occupied?(t()) :: boolean()
  def occupied?(%__MODULE__{piece: %Piece{}}), do: true
  def occupied?(_), do: false
end
