defmodule Chess.Board.Square do
  @moduledoc """
  Representation of a square on a chess board.
  """
  alias Chess.Piece

  @spec occupiable?(Piece.t(), Piece.t()) :: boolean()
  def occupiable?(%Piece{color: color}, %Piece{color: color}), do: false

  def occupiable?(%Piece{color: _color}, %Piece{color: _other_color}),
    do: true

  def occupiable?(%Piece{}, nil), do: false
  def occupiable?(nil, _), do: true

  @spec occupied?(Piece.t()) :: boolean()
  def occupied?(%Piece{}), do: true
  def occupied?(_), do: false
end
