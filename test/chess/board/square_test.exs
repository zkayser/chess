defmodule Chess.Board.SquareTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board.Square
  alias Chess.Piece

  describe "occupiable/2" do
    test "returns false if the square given is occupied by a piece of the same color" do
      square = %Piece{color: :white}
      refute Square.occupiable?(square, %Piece{color: :white})
    end

    test "returns true if the square given is occupied by a piece of the opposite color" do
      square = %Piece{color: :black}
      assert Square.occupiable?(square, %Piece{color: :white})
    end

    test "returns true if the square given is empty" do
      assert Square.occupiable?(nil, %Piece{color: :white})
    end
  end

  describe "occupied?/1" do
    test "returns false if the square given is not occupied by a chess piece" do
      refute Square.occupied?(nil)
    end

    test "returns true if the square given contains a chess piece" do
      assert Square.occupied?(%Piece{})
    end
  end
end
