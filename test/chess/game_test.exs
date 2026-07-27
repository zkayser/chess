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

  describe "opponent/1" do
    test "returns black when white is to move" do
      assert Game.opponent(%Game{current_player: :white}) == :black
    end

    test "returns white when black is to move" do
      assert Game.opponent(%Game{current_player: :black}) == :white
    end
  end
end
