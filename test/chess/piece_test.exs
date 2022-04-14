defmodule Chess.PieceTest do
  use ExUnit.Case
  doctest Chess.Piece

  alias Chess.Piece
  alias Chess.Pieces.{Bishop, King, Knight, Pawn, Queen, Rook}

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
        assert %Piece{type: Pawn} = Piece.for_starting_position(unquote(pawn_index))
      end
    end

    for rook_index <- @rook_indices do
      test "places a rook at #{rook_index} index" do
        assert %Piece{type: Rook} = Piece.for_starting_position(unquote(rook_index))
      end
    end

    for knight_index <- @knight_indices do
      test "places a knight at #{knight_index} index" do
        assert %Piece{type: Knight} = Piece.for_starting_position(unquote(knight_index))
      end
    end

    for bishop_index <- @bishop_indices do
      test "places a bishop at #{bishop_index} index" do
        assert %Piece{type: Bishop} = Piece.for_starting_position(unquote(bishop_index))
      end
    end

    for queen_index <- @queen_indices do
      test "places a queen at #{queen_index} index" do
        assert %Piece{type: Queen} = Piece.for_starting_position(unquote(queen_index))
      end
    end

    for king_index <- @king_indices do
      test "places a king at #{king_index} index" do
        assert %Piece{type: King} = Piece.for_starting_position(unquote(king_index))
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

  describe "String.Chars" do
    test "returns ♝ for Bishops" do
      assert " ♝ " == to_string(%Piece{type: Bishop})
    end

    test "returns  ♟️  for Pawns" do
      assert " ♟️ " == to_string(%Piece{type: Pawn})
    end

    test "returns  ♜  for Rooks" do
      assert " ♜ " == to_string(%Piece{type: Rook})
    end

    test "returns  ♞  for Knights" do
      assert " ♞ " == to_string(%Piece{type: Knight})
    end

    test "returns  ♛  for Queens" do
      assert " ♛ " == to_string(%Piece{type: Queen})
    end

    test "returns  ♚  for Kings" do
      assert " ♚ " == to_string(%Piece{type: King})
    end
  end

  describe "Inspect protocol" do
    @opening_ansi_code_white "\e[1;47;37m"
    @opening_ansi_code_black "\e[1;40;37m"
    @closing_ansi_code "\e[0m"
    test "returns custom representation of chess pieces with white color" do
      piece = %Piece{type: Enum.random([Bishop, Pawn, Rook, Knight, Queen, King]), color: :white}

      assert "#{@opening_ansi_code_white}#{to_string(piece)}#{@closing_ansi_code}" ==
               inspect(piece)
    end

    test "returns customer representation of chess pieces with black color" do
      piece = %Piece{type: Enum.random([Bishop, Pawn, Rook, Knight, Queen, King]), color: :black}

      assert "#{@opening_ansi_code_black}#{to_string(piece)}#{@closing_ansi_code}" ==
               inspect(piece)
    end
  end
end
