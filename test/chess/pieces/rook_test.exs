defmodule Chess.Pieces.RookTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Piece
  alias Chess.Pieces.Rook
  alias Chess.Test.BoardHelpers

  describe "potential_moves/3 with an empty board" do
    setup do
      {:ok, board: BoardHelpers.empty_board()}
    end

    for [corner_position, potential_move] <-
          for(
            {start_col, start_row} = corner <- [{1, 1}, {8, 8}],
            candidate <-
              Enum.concat(
                Enum.map(1..8, fn x -> {start_col, x} end),
                Enum.map(1..8, fn x -> {x, start_row} end)
              ),
            candidate != corner,
            do: [corner, candidate]
          ) do
      test "allows rook starting at corner position #{inspect(corner_position)} to move to #{inspect(potential_move)}",
           %{board: board} do
        rook = %Piece{type: Rook}
        starting_index = Board.coordinates_to_index(unquote(corner_position))
        board = %Board{board | grid: :array.set(starting_index, rook, board.grid)}

        assert MapSet.member?(
                 Rook.potential_moves(rook, starting_index, board),
                 Board.coordinates_to_index(unquote(potential_move))
               )
      end
    end
  end
end
