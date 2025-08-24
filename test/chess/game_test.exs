defmodule Chess.GameTest do
  use ExUnit.Case
  import Bitwise

  alias Chess.Boards.BitBoard
  alias Chess.Color
  alias Chess.Game

  describe "new/0" do
    test "creates a new chess game instance" do
      assert %Game{board: BitBoard.new(), move_list: [], current_player: Color.white()} ==
               Game.new()
    end
  end

  describe "apply_move/2" do
    test "en passant capture removes the captured pawn" do
      # White pawn at c5 (29) captures en passant on d6 (20)
      # The captured black pawn is at d5 (28)
      white_pawns = BitBoard.from_integer(1 <<< (63-29))
      black_pawns = BitBoard.from_integer(1 <<< (63-28))
      empty_board = BitBoard.empty()
      board = %BitBoard{
        white: %{pawns: white_pawns, rooks: empty_board, knights: empty_board, bishops: empty_board, queens: empty_board, king: empty_board},
        black: %{pawns: black_pawns, rooks: empty_board, knights: empty_board, bishops: empty_board, queens: empty_board, king: empty_board}
      }

      game = %Game{
        board: board,
        current_player: :white,
        en_passant_target: 20
      }

      move = %Chess.Move{from: 29, to: 20}

      # Bypass validation and call apply_move directly
      new_game = Game.apply_move(game, move)

      # The black pawn at d5 (28) should be gone.
      refute BitBoard.square_occupied?(BitBoard.get(new_game.board, :black), {"d", 5})
    end
  end
end
