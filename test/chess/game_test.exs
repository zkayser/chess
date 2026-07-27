defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
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

  describe "apply_candidate_move/4" do
    test "moves a piece onto an empty square" do
      game = game_with([{{:white, :king}, {"e", 1}}])

      after_move = Game.apply_candidate_move(game, :king, {"e", 1}, {"e", 2})

      assert BitBoard.get_raw(after_move.board, {:white, :king}) == Square.bitboard({"e", 2})
    end

    test "captures an opponent piece on the destination square" do
      game =
        game_with([
          {{:white, :king}, {"e", 1}},
          {{:black, :pawns}, {"f", 2}}
        ])

      after_move = Game.apply_candidate_move(game, :king, {"e", 1}, {"f", 2})

      assert BitBoard.get_raw(after_move.board, {:white, :king}) == Square.bitboard({"f", 2})
      assert BitBoard.get_raw(after_move.board, {:black, :pawns}) == 0
    end

    test "does not clear friendly pieces from unrelated squares" do
      game =
        game_with([
          {{:white, :king}, {"e", 1}},
          {{:white, :pawns}, {"a", 2}},
          {{:black, :rooks}, {"h", 8}}
        ])

      after_move = Game.apply_candidate_move(game, :king, {"e", 1}, {"d", 1})

      assert BitBoard.get_raw(after_move.board, {:white, :pawns}) == Square.bitboard({"a", 2})
      assert BitBoard.get_raw(after_move.board, {:black, :rooks}) == Square.bitboard({"h", 8})
    end
  end

  defp game_with(pieces) do
    %Game{board: board_with(pieces)}
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
