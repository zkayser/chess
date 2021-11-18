defmodule Chess.Board.SquareTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board.Square
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
end
