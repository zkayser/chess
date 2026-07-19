defmodule Chess.BitBoards.Pieces.KingTest do
  use ExUnit.Case, async: true

  alias Chess.Bitboards.Move
  alias Chess.BitBoards.Pieces.King
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

    test "rejects a move onto a square occupied by an own piece" do
      # Board state: White king on e1, white pawn on e2.
      # Move: e1 -> e2
      # Expected: {:error, :self_capture}
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
      # 2 |   |   |   |   | P |   |   |   |  <- own pawn blocks
      #   +---+---+---+---+---+---+---+---+
      # 1 |   |   |   |   | K |   |   |   |  <- white king
      #   +---+---+---+---+---+---+---+---+
      game =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:white, :pawns}, {"e", 2}}
        ])
        |> then(&%Game{board: &1})

      proposal = %Proposals{source: {"e", 1}, destination: {"e", 2}}

      assert {:error, :self_capture} = King.validate_move(game, proposal)
    end

    test "accepts a capture of an opponent piece" do
      # Board state: White king on e1, black pawn on f2.
      # Move: e1 -> f2 (capture pawn)
      # Expected: {:ok, %Move{from: {"e", 1}, to: {"f", 2}, flag: :captures}}
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
      # 2 |   |   |   |   |   | p |   |   |  <- black pawn (capture target)
      #   +---+---+---+---+---+---+---+---+
      # 1 |   |   |   |   | K |   |   |   |  <- white king
      #   +---+---+---+---+---+---+---+---+
      game =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :pawns}, {"f", 2}}
        ])
        |> then(&%Game{board: &1})

      proposal = %Proposals{source: {"e", 1}, destination: {"f", 2}}

      assert {:ok, %Move{from: {"e", 1}, to: {"f", 2}, flag: :captures}} =
               King.validate_move(game, proposal)
    end
  end

  defp game_with_white_king_on(square) do
    %Game{board: board_with([{{:white, :king}, square}])}
  end

  defp board_with(pieces) do
    empty = BitBoard.empty()

    empty_pieces = %{
      pawns: empty,
      rooks: empty,
      knights: empty,
      bishops: empty,
      queens: empty,
      king: empty
    }

    Enum.reduce(pieces, %BitBoard{white: empty_pieces, black: empty_pieces}, fn
      {{color, piece_type}, square}, board ->
        put_in(board[{color, piece_type}], BitBoard.from_integer(Square.bitboard(square)))
    end)
  end
end
