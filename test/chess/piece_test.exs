defmodule Chess.PieceTest do
  use ExUnit.Case
  doctest Chess.Piece

  alias Chess.Piece

  describe "for_starting_position/1" do
    @pawn_indices Enum.concat(8..15, 48..55)
    @rook_indices [0, 7, 56, 63]
    @knight_indices [1, 6, 57, 62]
    @bishop_indices [2, 5, 58, 61]
    @queen_indices [3, 59]
    @king_indices [4, 60]
    @empty_squares 16..47

    for pawn_index <- @pawn_indices do
      test "places a pawn at #{pawn_index} index" do
        assert %Piece{type: :pawn} = Piece.for_starting_position(unquote(pawn_index))
      end
    end

    for rook_index <- @rook_indices do
      test "places a rook at #{rook_index} index" do
        assert %Piece{type: :rook} = Piece.for_starting_position(unquote(rook_index))
      end
    end

    for knight_index <- @knight_indices do
      test "places a knight at #{knight_index} index" do
        assert %Piece{type: :knight} = Piece.for_starting_position(unquote(knight_index))
      end
    end

    for bishop_index <- @bishop_indices do
      test "places a bishop at #{bishop_index} index" do
        assert %Piece{type: :bishop} = Piece.for_starting_position(unquote(bishop_index))
      end
    end

    for queen_index <- @queen_indices do
      test "places a queen at #{queen_index} index" do
        assert %Piece{type: :queen} = Piece.for_starting_position(unquote(queen_index))
      end
    end

    for king_index <- @king_indices do
      test "places a king at #{king_index} index" do
        assert %Piece{type: :king} = Piece.for_starting_position(unquote(king_index))
      end
    end

    for empty_square <- @empty_squares do
      test "index #{empty_square} is empty" do
        assert is_nil(Piece.for_starting_position(unquote(empty_square)))
      end
    end

    for black_piece <- 0..15 do
      test "piece at index #{black_piece} is colored black" do
        assert %Piece{color: :black} = Piece.for_starting_position(unquote(black_piece))
      end
    end

    for white_piece <- 48..63 do
      test "piece at index #{white_piece} is colored white" do
        assert %Piece{color: :white} = Piece.for_starting_position(unquote(white_piece))
      end
    end
  end
end
