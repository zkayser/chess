defmodule Chess.BoardTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Board.Square
  alias Chess.Piece

  describe "layout/0" do
    test "creates a board of 64 squares" do
      board = Board.layout()
      assert :array.size(board.board) == 64
      :array.map(fn _, square -> match?(%Square{}, square) end, board.board)
    end

    test "places chess pieces on squares 0 through 15 and 48 through 63" do
      board = Board.layout()

      for non_empty_square <- Enum.concat(0..15, 48..63) do
        assert %Square{piece: %Piece{}} = :array.get(non_empty_square, board.board)
      end
    end

    test "square 16 through 47 are empty" do
      board = Board.layout()

      for empty_square <- 16..47 do
        assert %Square{piece: nil} = :array.get(empty_square, board.board)
      end
    end
  end

  describe "bounds/0" do
    test "returns the range giving bounds of a chess board" do
      assert 0..63 == Board.bounds()
    end
  end

  describe "in_bounds?/1" do
    test "returns true when the given index is within the bounds of a chess board" do
      assert Board.in_bounds?(Enum.random(Board.bounds()))
    end

    test "returns false when given index is outside of bounds of a chess board" do
      invalid_index =
        [
          StreamData.map(StreamData.positive_integer(), fn index -> -index end),
          StreamData.map(StreamData.positive_integer(), fn index -> index + 64 end)
        ]
        |> StreamData.one_of()
        |> Enum.take(1)
        |> List.first()

      refute Board.in_bounds?(invalid_index)
    end
  end

  describe "square_at/2" do
    test "returns the square at the given index" do
      assert %Square{
               color: :white,
               piece: %Piece{type: Chess.Pieces.Rook, color: :black, moves: []}
             } == Board.square_at(Board.layout(), 0)
    end
  end

  describe "Access callbacks" do
    setup do
      {:ok, board: Board.layout()}
    end

    test "fetch/2 returns the square at the given index when index is between 0 and 63", %{
      board: board
    } do
      assert %Square{} = board[Enum.random(Board.bounds())]
    end

    test "fetch/2 returns an error when the given index is invalid", %{board: board} do
      assert is_nil(board[-1])
    end

    test "fetch/2 returns the square at the given column, row combination", %{board: board} do
      index = Enum.random(Board.bounds())
      {column, row} = {rem(index, 8) + 1, div(index, 8) + 1}

      assert %Square{} = board[{column, row}]
    end

    test "get_and_update/3 allows squares to be updated", %{board: board} do
      new_square = %Square{
        color: :white,
        piece: %Piece{type: Chess.Pieces.King, color: :white, moves: []}
      }

      current_square = %Square{
        color: :white,
        piece: %Piece{type: Chess.Pieces.Rook, color: :black, moves: []}
      }

      assert {^current_square, new_board} =
               Board.get_and_update(board, 0, fn current -> {current, new_square} end)

      assert new_square == new_board[0]
    end

    test "pop/2 returns the square at the given index but is a no-op on the board", %{
      board: board
    } do
      square = %Square{
        color: :white,
        piece: %Piece{type: Chess.Pieces.Rook, color: :black, moves: []}
      }

      assert {^square, ^board} = Board.pop(board, 0)
    end

    test "pop/2 returns nil and the unmodified board if an invalid index is given", %{
      board: board
    } do
      assert {nil, ^board} = Board.pop(board, -1)
    end
  end
end
