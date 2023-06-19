defmodule Chess.Bitboards.SliderTest do
  use ExUnit.Case

  alias Chess.Bitboards.Slider

  describe "Slider" do
    test "is a struct containing a list of deltas" do
      assert %Slider{deltas: [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]}
    end
  end
end
