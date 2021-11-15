defmodule Chess.Board.SquareTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board.Square
  require Integer

  describe "init/1" do
    property "returns a white square when given parameter is even" do
      check all index <- filter(integer(0..64), &Integer.is_even/1) do
        assert %Square{color: :white} = Square.init(index)
      end
    end
  end
end
