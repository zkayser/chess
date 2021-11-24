defmodule Chess.Board.SquareTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board.Square
  alias Chess.Piece
  require Integer

  describe "init/1" do
    property "returns a white square when given index is even" do
      check all(index <- filter(integer(0..63), &Integer.is_even/1)) do
        assert %Square{color: :white} = Square.init(index)
      end
    end

    property "returns a black square when given index is odd" do
      check all(index <- filter(integer(0..63), &Integer.is_odd/1)) do
        assert %Square{color: :black} = Square.init(index)
      end
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
