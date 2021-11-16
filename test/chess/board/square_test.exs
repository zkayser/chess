defmodule Chess.Board.SquareTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board.Square
  require Integer

  describe "init/1" do
    @pawn_indices Enum.concat(8..15, 48..55)

    property "returns a white square when given index is even" do
      check all index <- filter(integer(0..64), &Integer.is_even/1) do
        assert %Square{color: :white} = Square.init(index)
      end
    end

    property "returns a black square when given index is odd" do
      check all index <- filter(integer(0..64), &Integer.is_odd/1) do
        assert %Square{color: :black} = Square.init(index)
      end
    end

    for pawn_index <- @pawn_indices do
      test "places a pawn at #{pawn_index} index" do
        assert %Square{piece: :pawn} = Square.init(unquote(pawn_index))
      end
    end
  end
end
