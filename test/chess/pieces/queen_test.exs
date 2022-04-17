defmodule Chess.Pieces.QueenTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Moves.Generators.Perpendiculars
  alias Chess.Piece
  alias Chess.Pieces.Queen
  alias Chess.Test.BoardHelpers

  describe "potential_moves/3 with empty board" do
    setup do
      {:ok, board: BoardHelpers.empty_board()}
    end

    test "given starting position at {4, 4}, can move in to any perpendicular spot", %{
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
  end
end
