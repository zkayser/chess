defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Game

  describe "new/0" do
    test "returns a new game instance with default board layout and active player set to `white`" do
      initial_board = Board.layout()

      assert %Game{board: ^initial_board, active_player: :white} = Game.new()
    end
  end
end
