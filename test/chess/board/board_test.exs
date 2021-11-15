defmodule Chess.BoardTest do
  use ExUnit.Case

  alias Chess.Board

  describe "layout/0" do
    test "creates a board of 64 squares" do
      assert length(Board.layout()) == 64
    end
  end
end
