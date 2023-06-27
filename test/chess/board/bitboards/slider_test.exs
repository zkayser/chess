defmodule Chess.Bitboards.SliderTest do
  use ExUnit.Case

  alias Chess.Bitboards.Slider

  describe "Slider struct" do
    test "is a struct containing a list of deltas" do
      assert %Slider{deltas: [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]}
    end
  end

  describe "rook/0" do
    test "returns the slider deltas for a rook sliding piece" do
      assert %Slider{deltas: [{1, 0}, {0, -1}, {-1, 0}, {0, 1}]} == Slider.rook()
    end
  end

  describe "bishop/0" do
    test "returns the slider deltas for a bishop sliding piece" do
      assert %Slider{deltas: [{1, 1}, {1, -1}, {-1, -1}, {-1, 1}]} == Slider.bishop()
    end
  end
end
