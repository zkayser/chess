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
