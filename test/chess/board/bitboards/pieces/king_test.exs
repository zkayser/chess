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

    test "accepts a quiet diagonal move" do
      # Board state: White king on d4, no obstructions.
      # Move: d4 -> e5 (diagonal NE)
      # Expected: {:ok, %Move{from: {"d", 4}, to: {"e", 5}, flag: :quiet}}
      #
      #     a   b   c   d   e   f   g   h
      #   +---+---+---+---+---+---+---+---+
      # 8 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 7 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 6 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 5 |   |   |   |   | * |   |   |   |  <- destination
      #   +---+---+---+---+---+---+---+---+
      # 4 |   |   |   | K |   |   |   |   |  <- white king
      #   +---+---+---+---+---+---+---+---+
      # 3 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 2 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 1 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      game = game_with_white_king_on({"d", 4})
      proposal = %Proposals{source: {"d", 4}, destination: {"e", 5}}

      assert {:ok, %Move{from: {"d", 4}, to: {"e", 5}, flag: :quiet}} =
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

    test "rejects a move that is more than one square away" do
      # Board state: White king on e1.
      # Move: e1 -> e3 (two squares — not valid king move, not castling)
      # Expected: {:error, :invalid_geometry}
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
      # 3 |   |   |   |   | X |   |   |   |  <- invalid destination
      #   +---+---+---+---+---+---+---+---+
      # 2 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 1 |   |   |   |   | K |   |   |   |  <- white king
      #   +---+---+---+---+---+---+---+---+
      game = game_with_white_king_on({"e", 1})
      proposal = %Proposals{source: {"e", 1}, destination: {"e", 3}}

      assert {:error, :invalid_geometry} = King.validate_move(game, proposal)
    end

    test "rejects a move onto a square attacked by an opponent rook" do
      # Board state: White king on e1, black rook on f8.
      # Move: e1 -> f1 (f-file is attacked by rook)
      # Expected: {:error, :king_in_check}
      #
      #     a   b   c   d   e   f   g   h
      #   +---+---+---+---+---+---+---+---+
      # 8 |   |   |   |   |   | r |   |   |  <- black rook controls f-file
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
      # 2 |   |   |   |   |   |   |   |   |
      #   +---+---+---+---+---+---+---+---+
      # 1 |   |   |   |   | K | X |   |   |  <- f1 attacked, can't go there
      #   +---+---+---+---+---+---+---+---+
      game =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :rooks}, {"f", 8}}
        ])
        |> then(&%Game{board: &1})

      proposal = %Proposals{source: {"e", 1}, destination: {"f", 1}}

      assert {:error, :king_in_check} = King.validate_move(game, proposal)
    end

    test "accepts a corner move to an adjacent diagonal square" do
      # Board state: White king on a1.
      # Move: a1 -> b2 (only 3 valid moves from a1: a2, b1, b2)
      # Expected: {:ok, %Move{from: {"a", 1}, to: {"b", 2}, flag: :quiet}}
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
      # 2 |   | * |   |   |   |   |   |   |  <- destination
      #   +---+---+---+---+---+---+---+---+
      # 1 | K |   |   |   |   |   |   |   |  <- white king in corner
      #   +---+---+---+---+---+---+---+---+
      game = game_with_white_king_on({"a", 1})
      proposal = %Proposals{source: {"a", 1}, destination: {"b", 2}}

      assert {:ok, %Move{from: {"a", 1}, to: {"b", 2}, flag: :quiet}} =
               King.validate_move(game, proposal)
    end
  end

  describe "in_check?/2" do
    test "returns false when the king is not under attack" do
      board = board_with([{{:white, :king}, {"e", 1}}])

      refute King.in_check?(board, :white)
    end

    test "returns true when an opponent rook attacks the king" do
      board =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :rooks}, {"e", 8}}
        ])

      assert King.in_check?(board, :white)
    end

    test "returns false when a friendly piece blocks an opponent rook" do
      board =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:white, :pawns}, {"e", 2}},
          {{:black, :rooks}, {"e", 8}}
        ])

      refute King.in_check?(board, :white)
    end

    test "returns true when an opponent bishop attacks the king diagonally" do
      board =
        board_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :bishops}, {"b", 4}}
        ])

      assert King.in_check?(board, :white)
    end

    test "returns true when an opponent knight attacks the king" do
      board =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :knights}, {"d", 6}}
        ])

      assert King.in_check?(board, :white)
    end

    test "returns true when an opponent pawn attacks the king" do
      board =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :pawns}, {"d", 5}}
        ])

      assert King.in_check?(board, :white)
    end

    test "returns true when an opponent king is adjacent" do
      board =
        board_with([
          {{:white, :king}, {"e", 4}},
          {{:black, :king}, {"e", 5}}
        ])

      assert King.in_check?(board, :white)
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
