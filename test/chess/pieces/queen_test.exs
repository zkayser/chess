defmodule Chess.Pieces.QueenTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board
  alias Chess.Moves.Generators.{Diagonals, Perpendiculars}
  alias Chess.Piece
  alias Chess.Pieces.Pawn
  alias Chess.Pieces.Queen
  alias Chess.Test.BoardHelpers

  describe "potential_moves/3 with empty board" do
    setup do
      {:ok, board: BoardHelpers.empty_board()}
    end

    test "given starting position at {4, 4}, can move to any perpendicular spot", %{
      board: board
    } do
      starting_index = Board.coordinates_to_index({4, 4})
      queen = %Piece{type: Queen, color: :white}

      board = %Board{board | grid: :array.set(starting_index, queen, board.grid)}

      perpendiculars = List.flatten(Perpendiculars.generate(starting_index))
      potential_moves = Queen.potential_moves(queen, starting_index, board)

      assert Enum.all?(perpendiculars, fn move -> move in potential_moves end),
             "Expected all moves in list:\n#{inspect(perpendiculars)}}\n to be included in potential_moves:\n#{inspect(potential_moves)}"
    end

    test "given starting position at {4, 4}, can move to any diagonal spot", %{board: board} do
      starting_index = Board.coordinates_to_index({4, 4})
      queen = %Piece{type: Queen, color: :white}

      board = %Board{board | grid: :array.set(starting_index, queen, board.grid)}

      diagonals = List.flatten(Diagonals.generate(starting_index))
      potential_moves = Queen.potential_moves(queen, starting_index, board)

      assert Enum.all?(diagonals, fn move -> move in potential_moves end),
             "Expected all moves in list:\n#{inspect(diagonals)}}\n to be included in potential_moves:\n#{inspect(potential_moves)}"
    end
  end

  describe "potential_moves/3 with non-empty board" do
    property "allows queens to move in any direction until a blocking piece is encountered" do
      check all(
              {column, row} <-
                StreamData.one_of([
                  StreamData.constant({4, 6}),
                  StreamData.constant({4, 2}),
                  StreamData.constant({6, 4}),
                  StreamData.constant({2, 4}),
                  StreamData.constant({2, 2}),
                  StreamData.constant({6, 6}),
                  StreamData.constant({6, 2}),
                  StreamData.constant({2, 6})
                ])
            ) do
        queen = %Piece{type: Queen, color: :white}

        other_piece = %Piece{type: Pawn, color: :white}

        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index({4, 4})
        other_piece_index = Board.coordinates_to_index({column, row})

        board = %Board{board | grid: :array.set(starting_index, queen, board.grid)}
        board = %Board{board | grid: :array.set(other_piece_index, other_piece, board.grid)}

        potential_moves = Queen.potential_moves(queen, starting_index, board)

        assert {column, row} not in potential_moves
      end
    end
  end
end
