defmodule Chess.Pieces.PawnTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board
  alias Chess.Piece
  alias Chess.Pieces.Pawn

  describe "potential_moves/3" do
    property "always returns a set of indices within the range 0 to 64" do
      check all(
              piece <- piece_generator(),
              starting_position <- integer(0..63)
            ) do
        moves = Pawn.potential_moves(piece, starting_position, Board.layout())

        for move <- moves do
          assert move >= 0 && move <= 64
        end
      end
    end
  end

  describe "potential_moves/3 with no prior moves taken at beginning of game" do
    for starting_index <- Enum.concat(8..15, 48..55) do
      test "allows the pawn starting at #{starting_index} to move up one or two rows" do
        {color, orientation} =
          case unquote(starting_index) <= 15 do
            true -> {:black, 1}
            false -> {:white, -1}
          end

        pawn = %Piece{type: Pawn, color: color, moves: []}

        assert MapSet.new([
                 unquote(starting_index) + 8 * orientation,
                 unquote(starting_index) + 16 * orientation
               ]) == Pawn.potential_moves(pawn, unquote(starting_index), Board.layout())
      end
    end
  end

  describe "potential_moves/3 with at least one prior move taken" do
    property "returns at most 3 potential moves where only 1 is a straight move and 2 are diagonal captures" do
      check all(piece <- piece_generator(), starting_position <- integer(0..63)) do
        piece =
          case piece.moves do
            [] -> %Piece{piece | moves: [Enum.random(0..63)]}
            _ -> piece
          end

        potential_moves = Pawn.potential_moves(piece, starting_position, Board.layout())
        assert Enum.count(potential_moves) <= 3

        {straight_moves, diagonal_captures} =
          Enum.split_with(potential_moves, fn index ->
            rem(abs(starting_position - index), 8) == 0
          end)

        assert Enum.count(straight_moves) <= 1
        assert Enum.count(diagonal_captures) <= 2
      end
    end
  end

  def piece_generator do
    gen all(
          type <- constant(Pawn),
          color <- StreamData.one_of([StreamData.constant(:white), StreamData.constant(:black)]),
          moves <- StreamData.list_of(integer(0..63))
        ) do
      %Piece{type: type, color: color, moves: moves}
    end
  end
end
