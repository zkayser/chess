defmodule Chess.Pieces.RookTest do
  use ExUnit.Case
  use ExUnitProperties

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

    test "allows rook to move up to but not including the spot of a piece of the same color" do
      board = BoardHelpers.empty_board()
      rook = %Piece{type: Rook, color: :white}
      cooperating_piece = %Piece{color: :white}

      our_starting_coords = {1, 1}
      other_piece_starting_coords = {1, 4}

      starting_index = Board.coordinates_to_index(our_starting_coords)
      other_piece_starting_index = Board.coordinates_to_index(other_piece_starting_coords)

      expected_potential_moves = [{1, 2}, {1, 3}] |> Enum.map(&Board.coordinates_to_index/1)

      non_potential_moves =
        [{1, 4}, {1, 5}, {1, 6}, {1, 7}, {1, 8}] |> Enum.map(&Board.coordinates_to_index/1)

      board = %Board{board | grid: :array.set(starting_index, rook, board.grid)}

      board = %Board{
        board
        | grid: :array.set(other_piece_starting_index, cooperating_piece, board.grid)
      }

      potential_moves = Rook.potential_moves(rook, starting_index, board)

      for move <- expected_potential_moves do
        assert MapSet.member?(potential_moves, move)
      end

      for non_move <- non_potential_moves do
        refute MapSet.member?(potential_moves, non_move)
      end
    end

    property "ensures rooks can only move up to but not including the spot of a piece of the same color on the same row" do
      check all({column, row} <- {StreamData.integer(1..8), StreamData.integer(1..8)}) do
        {other_col, _row} =
          other_piece_coordinates = {Enum.random(Enum.reject(1..8, &(&1 == column))), row}

        board = BoardHelpers.empty_board()
        rook = %Piece{type: Rook, color: :white}
        cooperating_piece = %Piece{color: :white}

        our_starting_coords = {column, row}
        starting_index = Board.coordinates_to_index(our_starting_coords)
        other_piece_starting_index = Board.coordinates_to_index(other_piece_coordinates)

        playable_columns =
          if column > other_col do
            Enum.concat((other_col + 1)..max(column - 1, 1), min(column + 1, 8)..8)
          else
            Enum.concat(1..max(column - 1, 1), min(column + 1, 8)..(other_col - 1))
          end

        expected_potential_moves =
          Enum.map(playable_columns, fn col -> {col, row} end)
          |> Enum.reject(fn coordinates ->
            coordinates == our_starting_coords || coordinates == other_piece_coordinates
          end)
          |> Enum.map(&Board.coordinates_to_index/1)

        board = %Board{board | grid: :array.set(starting_index, rook, board.grid)}

        board = %Board{
          board
          | grid: :array.set(other_piece_starting_index, cooperating_piece, board.grid)
        }

        actual_potential_moves = Rook.potential_moves(rook, starting_index, board)

        for potential_move <- expected_potential_moves do
          assert MapSet.member?(actual_potential_moves, potential_move),
                 "Expected #{inspect(Board.index_to_coordinates(potential_move))} (#{inspect(potential_move)}) to be included in potential moves for Rook at starting coordinates #{inspect(our_starting_coords)}"
        end
      end
    end
  end
end
