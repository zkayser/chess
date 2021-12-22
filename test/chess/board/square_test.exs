defmodule Chess.Board.SquareTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board.Square
  alias Chess.Piece

  describe "occupiable/2" do
    test "returns false if the square given is occupied by a piece of the same color" do
      square = %Square{piece: %Piece{color: :white}}
      refute Square.occupiable?(square, %Piece{color: :white})
    end

    test "returns true if the square given is occupied by a piece of the opposite color" do
      square = %Square{piece: %Piece{color: :black}}
      assert Square.occupiable?(square, %Piece{color: :white})
    end

    test "returns true if the square given is empty" do
      square = %Square{piece: nil}
      assert Square.occupiable?(square, %Piece{color: :white})
    end
  end

  describe "occupied?/1" do
    test "returns false if the square given is not occupied by a chess piece" do
      refute Square.occupied?(%Square{piece: nil})
    end

    test "returns true if the square given contains a chess piece" do
      assert Square.occupied?(%Square{piece: %Piece{}})
    end
  end
end
