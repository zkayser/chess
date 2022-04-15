defmodule Chess.Moves.FiltersTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Moves.Filters
  alias Chess.Moves.Generators.{Diagonals, Perpendiculars}
  alias Chess.Piece
  alias Chess.Pieces.Rook
  alias Chess.Test.BoardHelpers

  describe "unreachable_coordinates/3" do
    test "reduces a set of moves in one direction down to coordinates not blocked by a friendly piece" do
      board = BoardHelpers.empty_board()
      piece = %Piece{type: Rook, color: :white}
      friendly_piece = %Piece{type: Rook, color: :white}

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 1}), piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 4}), friendly_piece, board.grid)
      }

      potential_moves_set = for x <- 2..8, do: {1, x}

      expected_filtered_moves = [{1, 2}, {1, 3}]

      assert MapSet.new(expected_filtered_moves) ==
               MapSet.new(Filters.unreachable_coordinates([potential_moves_set], piece, board))
    end

    test "reduces a set of moves in one direction up to and including an opposing piece but not beyond" do
      board = BoardHelpers.empty_board()
      piece = %Piece{type: Rook, color: :white}
      opposing_piece = %Piece{type: Rook, color: :black}

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 1}), piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 4}), opposing_piece, board.grid)
      }

      potential_moves_set = for x <- 2..8, do: {1, x}

      expected_filtered_moves = [{1, 2}, {1, 3}, {1, 4}]

      assert MapSet.new(expected_filtered_moves) ==
               MapSet.new(Filters.unreachable_coordinates([potential_moves_set], piece, board))
    end

    test "takes a list of MapSets and filters moves up to a friendly piece's position" do
      board = BoardHelpers.empty_board()
      piece = %Piece{type: Rook, color: :white}
      friendly_piece = %Piece{type: Rook, color: :white}

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 1}), piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 4}), friendly_piece, board.grid)
      }

      potential_moves_set = MapSet.new(for x <- 2..8, do: {1, x})

      expected_filtered_moves = [{1, 2}, {1, 3}]

      assert MapSet.new(expected_filtered_moves) ==
               MapSet.new(Filters.unreachable_coordinates([potential_moves_set], piece, board))
    end

    test "takes a list of MapSets and filters moves up to and including an opposing piece's position" do
      board = BoardHelpers.empty_board()
      piece = %Piece{type: Rook, color: :white}
      opposing_piece = %Piece{type: Rook, color: :black}

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 1}), piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({1, 4}), opposing_piece, board.grid)
      }

      potential_moves_set = MapSet.new(for x <- 2..8, do: {1, x})

      expected_filtered_moves = [{1, 2}, {1, 3}, {1, 4}]

      assert MapSet.new(expected_filtered_moves) ==
               MapSet.new(Filters.unreachable_coordinates([potential_moves_set], piece, board))
    end

    test "limits moves in all directions up to where a piece can move no further due to obstruction" do
      board = BoardHelpers.empty_board()
      piece = %Piece{type: Rook, color: :white}
      opposing_piece = %Piece{type: Rook, color: :black}

      starting_coords = {4, 4}
      starting_index = Board.coordinates_to_index(starting_coords)

      board = %Board{
        board
        | grid: :array.set(starting_index, piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({2, 4}), opposing_piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({6, 4}), opposing_piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({4, 2}), opposing_piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({4, 6}), opposing_piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({2, 2}), opposing_piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({6, 6}), opposing_piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({6, 2}), opposing_piece, board.grid)
      }

      board = %Board{
        board
        | grid: :array.set(Board.coordinates_to_index({2, 6}), opposing_piece, board.grid)
      }

      potential_diagonal_moves = Diagonals.generate(starting_index)

      potential_perpendicular_moves = Perpendiculars.generate(starting_index)

      expected_left = [{3, 4}, {2, 4}]
      expected_right = [{5, 4}, {6, 4}]
      expected_below = [{4, 3}, {4, 2}]
      expected_above = [{4, 5}, {4, 6}]
      expected_quadrant_1 = [{3, 3}, {2, 2}]
      expected_quadrant_2 = [{5, 5}, {6, 6}]
      expected_quadrant_3 = [{5, 3}, {6, 2}]
      expected_quadrant_4 = [{3, 5}, {2, 6}]

      filtered_list =
        MapSet.new(
          Filters.unreachable_coordinates(
            Stream.concat(potential_diagonal_moves, potential_perpendicular_moves),
            piece,
            board
          )
        )

      expected =
        List.flatten([
          expected_left,
          expected_right,
          expected_below,
          expected_above,
          expected_quadrant_1,
          expected_quadrant_2,
          expected_quadrant_3,
          expected_quadrant_4
        ])

      assert MapSet.new(expected) == filtered_list
    end
  end
end
