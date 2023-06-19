defmodule Chess.Bitboards.SliderTest do
  use ExUnit.Case

  alias Chess.Bitboards.Slider

  describe "Slider struct" do
    test "is a struct containing a list of deltas" do
      assert %Slider{deltas: [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]}
    end
  end

  describe "rook/0" do
    test "returns the deltas for sliding a rook piece" do
      assert %Slider{deltas: [{1, 0}, {0, -1}, {-1, 0}, {0, 1}]} == Slider.rook()
    end
  end
end
