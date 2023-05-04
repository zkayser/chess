defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.Boards.BitBoard
  alias Chess.Color
  alias Chess.Game

  describe "new/0" do
    test "creates a new chess game instance" do
      assert %Game{board: BitBoard.new(), move_list: [], current_player: Color.white()} ==
               Game.new()
    end
  end
end
