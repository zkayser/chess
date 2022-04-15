defmodule Chess.Pieces.BishopTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board
  alias Chess.Moves.Generators.Diagonals
  alias Chess.Piece
  alias Chess.Pieces.Bishop
  alias Chess.Test.BoardHelpers

  describe "potential_moves/3 with empty board" do
    setup do
      {:ok, board: BoardHelpers.empty_board()}
    end

    for [corner_position, potential_move] <-
          for(
            corner <- [{1, 1}, {8, 8}],
            candidate <- Enum.map(1..8, fn x -> {x, x} end),
            candidate != corner,
            do: [corner, candidate]
          ) do
      test "allows bishop starting at corner position #{inspect(corner_position)} to move to #{inspect(potential_move)}",
           %{board: board} do
        bishop = %Piece{type: Bishop}
        starting_index = Board.coordinates_to_index(unquote(corner_position))
        board = %Board{board | grid: :array.set(starting_index, bishop, board.grid)}

        potential_moves = Bishop.potential_moves(bishop, starting_index, board)
        expected_index = Board.coordinates_to_index(unquote(potential_move))

        assert MapSet.member?(potential_moves, expected_index),
               "Expected #{inspect(expected_index)} (coordinate #{inspect(unquote(potential_move))}) to be in #{inspect(potential_moves)}, but it was not. \nInstead got #{inspect(Enum.map(potential_moves, fn m -> Board.index_to_coordinates(m) end))}"
      end
    end

    test "allows a bishop starting at position {4, 4} to move all along diagonals", %{
      board: board
    } do
      bishop = %Piece{type: Bishop}
      starting_index = Board.coordinates_to_index({4, 4})
      board = %Board{board | grid: :array.set(starting_index, bishop, board.grid)}

      potential_moves = Bishop.potential_moves(bishop, starting_index, board)

      diagonal_1 = [{1, 1}, {2, 2}, {3, 3}, {5, 5}, {6, 6}, {7, 7}, {8, 8}]
      diagonal_2 = [{5, 3}, {6, 2}, {7, 1}, {3, 5}, {2, 6}, {1, 7}]

      expected =
        diagonal_1
        |> Enum.concat(diagonal_2)
        |> Enum.map(fn coords -> Board.coordinates_to_index(coords) end)
        |> MapSet.new()

      assert MapSet.equal?(potential_moves, expected),
             "Expected potential moves #{inspect(potential_moves)}\nto equal\n#{inspect(expected)}"
    end
  end

  describe "potential_moves/3 with non-empty board" do
    property "ensures rooks can only move up to but not including the spot of a piece of the same color on the same diagonal" do
      check all({column, row} <- {StreamData.integer(2..7), StreamData.integer(2..7)}) do
        diagonals =
          Diagonals.generate(Board.coordinates_to_index({column, row})) |> List.flatten()

        other_piece_coordinates = Enum.random(diagonals)

        board = BoardHelpers.empty_board()

        bishop = %Piece{type: Bishop, color: :white}
        cooperating_piece = %Piece{color: :white}
        our_starting_coords = {column, row}
        starting_index = Board.coordinates_to_index(our_starting_coords)
        other_piece_starting_index = Board.coordinates_to_index(other_piece_coordinates)

        board = %Board{board | grid: :array.set(starting_index, bishop, board.grid)}

        board = %Board{
          board
          | grid: :array.set(other_piece_starting_index, cooperating_piece, board.grid)
        }

        potential_moves = Bishop.potential_moves(bishop, starting_index, board)

        refute Enum.empty?(potential_moves)
        refute Enum.member?(potential_moves, other_piece_starting_index)
      end
    end

    property "ensures rooks can only move up to and including the spot of a piece of the opposite color on the same diagonal" do
      check all({column, row} <- {StreamData.integer(2..7), StreamData.integer(2..7)}) do
        diagonals =
          Diagonals.generate(Board.coordinates_to_index({column, row})) |> List.flatten()

        other_piece_coordinates = Enum.random(diagonals)

        board = BoardHelpers.empty_board()

        bishop = %Piece{type: Bishop, color: :white}
        opponent_piece = %Piece{color: :black}
        our_starting_coords = {column, row}
        starting_index = Board.coordinates_to_index(our_starting_coords)
        other_piece_starting_index = Board.coordinates_to_index(other_piece_coordinates)

        board = %Board{board | grid: :array.set(starting_index, bishop, board.grid)}

        board = %Board{
          board
          | grid: :array.set(other_piece_starting_index, opponent_piece, board.grid)
        }

        potential_moves = Bishop.potential_moves(bishop, starting_index, board)

        refute Enum.empty?(potential_moves)
        assert Enum.member?(potential_moves, other_piece_starting_index)
      end
    end
  end
end
