defmodule Chess.GameTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board
  alias Chess.Game
  alias Chess.Piece

  describe "new/0" do
    test "returns a new game instance with default board layout and active player set to `white`" do
      initial_board = Board.layout()

      assert %Game{board: ^initial_board, active_player: :white} = Game.new()
    end
  end

  describe "play/2" do
    property "returns an ok tuple with the updated game instance when the given move is valid" do
      check all(index <- StreamData.integer(48..63)) do
        game = Game.new()
        piece = game.board[index]
        potential_moves = Piece.potential_moves(piece, index, game.board)

        for move <- potential_moves do
          assert {:ok, updated_game} = Game.play(game, %{player: :white, from: index, to: move})

          assert updated_game.board[move] == piece,
                 "Expected piece #{piece} to be moved to position #{move}, but it was not"

          refute updated_game.board[index] == piece,
                 "Expected piece #{piece} to be moved from index position #{index}, but it was not"
        end
      end
    end
  end
end
