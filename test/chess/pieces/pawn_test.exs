defmodule Chess.Pieces.PawnTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Boards.BitBoard
  alias Chess.Piece
  alias Chess.Pieces.Pawn

  describe "potential_moves/3" do
    property "always returns a set of indices within the range 0 to 64" do
      check all(
              piece <- piece_generator(),
              starting_position <- integer(0..63)
            ) do
        game = %Chess.Game{board: BitBoard.new()}
        moves = Pawn.potential_moves(piece, starting_position, game)

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

        pawn = %Piece{type: Pawn, color: color, moves: MapSet.new()}
        game = %Chess.Game{board: BitBoard.new()}

        assert MapSet.new([
                 unquote(starting_index) + 8 * orientation,
                 unquote(starting_index) + 16 * orientation
               ]) == Pawn.potential_moves(pawn, unquote(starting_index), game)
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

        game = %Chess.Game{board: BitBoard.new()}
        potential_moves = Pawn.potential_moves(piece, starting_position, game)
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

  describe "potential_moves/3 with en passant" do
    test "allows en passant capture for white pawn" do
      # Black pawn at d7 (11) moves to d5 (27), en passant target is d6 (19)
      # White pawn at c5 (26) should be able to capture en passant at d6 (19)
      game = %Chess.Game{
        board: BitBoard.new(),
        current_player: :white,
        en_passant_target: 19
      }

      # Moved from c2
      pawn = %Piece{type: Pawn, color: :white, moves: MapSet.new([42])}
      moves = Pawn.potential_moves(pawn, 26, game)
      assert MapSet.member?(moves, 19)
    end

    test "allows en passant capture for black pawn" do
      # White pawn at e2 (52) moves to e4 (36), en passant target is e3 (44)
      # Black pawn at d4 (35) should be able to capture en passant at e3 (44)
      game = %Chess.Game{
        board: BitBoard.new(),
        current_player: :black,
        en_passant_target: 44
      }

      # Moved from d7
      pawn = %Piece{type: Pawn, color: :black, moves: MapSet.new([11])}
      moves = Pawn.potential_moves(pawn, 35, game)
      assert MapSet.member?(moves, 44)
    end

    test "does not allow en passant if target is not set" do
      # Same setup as "allows en passant capture for white pawn", but en_passant_target is nil
      game = %Chess.Game{
        board: BitBoard.new(),
        current_player: :white,
        en_passant_target: nil
      }

      pawn = %Piece{type: Pawn, color: :white, moves: MapSet.new([42])}
      moves = Pawn.potential_moves(pawn, 26, game)
      refute MapSet.member?(moves, 19)
    end

    test "does not allow en passant if pawn is on wrong rank" do
      # White pawn at c4 (34), not on rank 5, so cannot capture en passant
      game = %Chess.Game{
        board: BitBoard.new(),
        current_player: :white,
        # en passant target is d6
        en_passant_target: 19
      }

      pawn = %Piece{type: Pawn, color: :white, moves: MapSet.new([42])}
      moves = Pawn.potential_moves(pawn, 34, game)
      refute MapSet.member?(moves, 19)
    end
  end
end
