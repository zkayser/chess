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
    property "returns at most 1 potential move" do
      check all(piece <- piece_generator(), starting_position <- integer(0..63)) do
        case piece.moves do
          [] ->
            assert Enum.count(
                     Pawn.potential_moves(
                       %Piece{piece | moves: [Enum.random(0..63)]},
                       starting_position,
                       Board.layout()
                     )
                   ) <=
                     1

          _ ->
            assert Enum.count(Pawn.potential_moves(piece, starting_position, Board.layout())) <= 1
        end
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
