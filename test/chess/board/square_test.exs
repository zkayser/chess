defmodule Chess.Board.SquareTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Board.Square
  require Integer

  describe "init/1" do
    @pawn_indices Enum.concat(8..15, 48..55)
    @rook_indices [0, 7, 56, 63]
    @knight_indices [1, 6, 57, 62]
    @bishop_indices [2, 5, 58, 61]
    @queen_indices [3, 59]
    @king_indices [4, 60]
    @empty_squares 16..47

    property "returns a white square when given index is even" do
      check all index <- filter(integer(0..64), &Integer.is_even/1) do
        assert %Square{color: :white} = Square.init(index)
      end
    end

    property "returns a black square when given index is odd" do
      check all index <- filter(integer(0..64), &Integer.is_odd/1) do
        assert %Square{color: :black} = Square.init(index)
      end
    end

    for pawn_index <- @pawn_indices do
      test "places a pawn at #{pawn_index} index" do
        assert %Square{piece: :pawn} = Square.init(unquote(pawn_index))
      end
    end

    for rook_index <- @rook_indices do
      test "places a rook at #{rook_index} index" do
        assert %Square{piece: :rook} = Square.init(unquote(rook_index))
      end
    end

    for knight_index <- @knight_indices do
      test "places a knight at #{knight_index} index" do
        assert %Square{piece: :knight} = Square.init(unquote(knight_index))
      end
    end

    for bishop_index <- @bishop_indices do
      test "places a bishop at #{bishop_index} index" do
        assert %Square{piece: :bishop} = Square.init(unquote(bishop_index))
      end
    end

    for queen_index <- @queen_indices do
      test "places a queen at #{queen_index} index" do
        assert %Square{piece: :queen} = Square.init(unquote(queen_index))
      end
    end

    for king_index <- @king_indices do
      test "places a king at #{king_index} index" do
        assert %Square{piece: :king} = Square.init(unquote(king_index))
      end
    end

    for empty_square <- @empty_squares do
      test "index #{empty_square} is empty" do
        assert %Square{piece: :empty} = Square.init(unquote(empty_square))
      end
    end
  end
end
