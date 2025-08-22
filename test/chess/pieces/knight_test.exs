defmodule Chess.Pieces.KnightTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Piece
  alias Chess.Pieces.Knight
  alias Chess.Test.BoardHelpers

  describe "potential_moves/3 with empty board," do
    for corner <- [{1, 1}, {1, 8}, {8, 1}, {8, 8}] do
      test "lists two moves for knights in corner position #{inspect(corner)}" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(corner))
        piece = %Piece{type: Knight}
        board = %Board{grid: :array.set(starting_index, piece, board.grid)}

        assert Enum.count(Knight.potential_moves(piece, starting_index, board)) == 2
      end
    end

    for edge <-
          Enum.flat_map(3..6, fn middle ->
            [{1, middle}, {8, middle}, {middle, 1}, {middle, 8}]
          end) do
      test "lists four potential moves for knights along vertical side #{inspect(edge)}" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(edge))
        piece = %Piece{type: Knight}
        board = %Board{grid: :array.set(starting_index, piece, board.grid)}

        assert Enum.count(Knight.potential_moves(piece, starting_index, board)) == 4
      end
    end

    for edge_adjacent <-
          Enum.flat_map(3..6, fn middle ->
            [{2, middle}, {7, middle}, {middle, 2}, {middle, 7}]
          end) do
      test "lists six potential moves for knights in edge-adjacent position #{inspect(edge_adjacent)}" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(edge_adjacent))
        piece = %Piece{type: Knight}
        board = %Board{grid: :array.set(starting_index, piece, board.grid)}

        assert Enum.count(Knight.potential_moves(piece, starting_index, board)) == 6
      end
    end

    for corner_adjacent <- [{1, 2}, {1, 7}, {2, 1}, {7, 1}] do
      test "lists three potential moves for knights in corner-adjacent position #{inspect(corner_adjacent)}" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(corner_adjacent))
        piece = %Piece{type: Knight}
        board = %Board{grid: :array.set(starting_index, piece, board.grid)}

        assert Enum.count(Knight.potential_moves(piece, starting_index, board)) == 3
      end
    end

    for inner_corner <- [{2, 2}, {2, 7}, {7, 2}, {7, 7}] do
      test "lists four potential moves for knights in inner corner position #{inspect(inner_corner)}" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(inner_corner))
        piece = %Piece{type: Knight}
        board = %Board{grid: :array.set(starting_index, piece, board.grid)}

        assert Enum.count(Knight.potential_moves(piece, starting_index, board)) == 4
      end
    end

    for middle <- for(x <- 3..6, y <- 6..3//-1, do: {x, y}) do
      test "lists eight potential moves for knights in middle position #{inspect(middle)}" do
        board = BoardHelpers.empty_board()
        starting_index = Board.coordinates_to_index(unquote(middle))
        piece = %Piece{type: Knight}
        board = %Board{grid: :array.set(starting_index, piece, board.grid)}

        assert Enum.count(Knight.potential_moves(piece, starting_index, board)) == 8
      end
    end
  end

  describe "potential_moves/3 starting in middle with non-empty board" do
    starting_coordinates = {4, 4}

    for reachable_coordinates <- [{3, 2}, {5, 2}, {2, 3}, {6, 3}, {2, 5}, {6, 5}, {3, 6}, {5, 6}] do
      test "black piece starting at #{inspect(starting_coordinates)} cannot replace black piece at #{inspect(reachable_coordinates)}" do
        board = BoardHelpers.empty_board()
        piece_1 = %Piece{color: :black, type: Knight}
        piece_2 = %Piece{color: :black, type: Knight}

        middle = Board.coordinates_to_index(unquote(starting_coordinates))
        reachable_coordinate = Board.coordinates_to_index(unquote(reachable_coordinates))

        board = %Board{board | grid: :array.set(middle, piece_1, board.grid)}
        board = %Board{board | grid: :array.set(reachable_coordinate, piece_2, board.grid)}

        refute MapSet.member?(
                 Knight.potential_moves(piece_1, middle, board),
                 reachable_coordinate
               )
      end

      test "black piece starting at #{inspect(starting_coordinates)} can overtake white piece at #{inspect(reachable_coordinates)}" do
        board = BoardHelpers.empty_board()
        piece_1 = %Piece{color: :black, type: Knight}
        piece_2 = %Piece{color: :white, type: Knight}

        middle = Board.coordinates_to_index(unquote(starting_coordinates))
        reachable_coordinate = Board.coordinates_to_index(unquote(reachable_coordinates))

        board = %Board{board | grid: :array.set(middle, piece_1, board.grid)}
        board = %Board{board | grid: :array.set(reachable_coordinate, piece_2, board.grid)}

        assert MapSet.member?(
                 Knight.potential_moves(piece_1, middle, board),
                 reachable_coordinate
               )
      end
    end
  end
end
