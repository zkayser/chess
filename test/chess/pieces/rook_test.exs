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

  describe "potential_moves/3 with non-empty board" do
    test "allows rook to move up to and including the spot of an opposing piece but not beyond" do
      board = BoardHelpers.empty_board()
      rook = %Piece{type: Rook, color: :white}
      opposing_piece = %Piece{color: :black}

      our_starting_coords = {1, 1}
      opponent_starting_coords = {1, 4}

      starting_index = Board.coordinates_to_index(our_starting_coords)
      opponent_starting_index = Board.coordinates_to_index(opponent_starting_coords)

      expected_potential_moves =
        [{1, 2}, {1, 3}, {1, 4}] |> Enum.map(&Board.coordinates_to_index/1)

      non_potential_moves =
        [{1, 5}, {1, 6}, {1, 7}, {1, 8}] |> Enum.map(&Board.coordinates_to_index/1)

      board = %Board{board | grid: :array.set(starting_index, rook, board.grid)}

      board = %Board{
        board
        | grid: :array.set(opponent_starting_index, opposing_piece, board.grid)
      }

      potential_moves = Rook.potential_moves(rook, starting_index, board)

      for move <- expected_potential_moves do
        assert MapSet.member?(potential_moves, move)
      end

      for non_move <- non_potential_moves do
        refute MapSet.member?(potential_moves, non_move)
      end
    end
  end
end
