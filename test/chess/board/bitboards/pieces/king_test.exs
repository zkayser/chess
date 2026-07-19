defmodule Chess.BitBoards.Pieces.KingTest do
  use ExUnit.Case, async: true

  alias Chess.BitBoards.Pieces.King
  alias Chess.Bitboards.Move
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
  alias Chess.Game
  alias Chess.Moves.Proposals

  describe "validate_move/2" do
    test "accepts a quiet move one square forward" do
      # Board state: White king on e1, no other pieces nearby.
      # Move: e1 -> e2 (one square forward)
      #
      #     a   b   c   d   e   f   g   h
      #   +---+---+---+---+---+---+---+---+
      # 8 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 7 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 6 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 5 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 4 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 3 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 2 |   |   |   |   | * |   |   |   |  <- destination
      #   +---+---+---+---+---+---+---+---+
      # 1 |   |   |   |   | K |   |   |   |  <- white king
      #   +---+---+---+---+---+---+---+---+
      game = game_with_white_king_on({"e", 1})
      proposal = %Proposals{source: {"e", 1}, destination: {"e", 2}}

      assert {:ok, %Move{from: {"e", 1}, to: {"e", 2}, flag: :quiet}} =
               King.validate_move(game, proposal)
    end
  end

  defp game_with_white_king_on(square) do
    empty = BitBoard.empty()

    board = %BitBoard{
      white: %{
        pawns: empty,
        rooks: empty,
        knights: empty,
        bishops: empty,
        queens: empty,
        king: BitBoard.from_integer(Square.bitboard(square))
      },
      black: %{
        pawns: empty,
        rooks: empty,
        knights: empty,
        bishops: empty,
        queens: empty,
        king: empty
      }
    }

    %Game{board: board}
  end
end
