defmodule Chess.Boards.BitBoardTest do
  use ExUnit.Case, async: true

  alias Chess.Boards.BitBoard

  describe "new/0" do
    test "creates a BitBoard struct with an atomics ref" do
      assert %BitBoard{ref: ref} = BitBoard.new()

      assert is_reference(ref),
             "Expected new bitboard to contain a reference, but contained #{inspect(ref)} instead."
    end
  end

  describe "list_types/0" do
    test "returns the list of all bitboard types" do
      expected_type_set =
        MapSet.new(
          ~w(composite black_composite white_composite white_pawns white_rooks white_knights white_bishops white_queens white_king black_pawns black_rooks black_knights black_bishops black_queens black_king)a
        )

      actual_set = MapSet.new(BitBoard.list_types())

      assert MapSet.equal?(actual_set, expected_type_set), """
      Expected set of Bitboard types to equal expected set.
      Actual: #{inspect(actual_set)}
      Expected: #{inspect(expected_type_set)}
      """
    end
  end

  describe "get/2" do
    for bitboard_type <- BitBoard.list_types() do
      test "returns bitboard when given #{bitboard_type}" do
        assert BitBoard.initial_states()[unquote(bitboard_type)] ==
                 BitBoard.get(BitBoard.new(), unquote(bitboard_type))
      end
    end
  end

  describe "to_grid/2" do
    test "returns an 8x8 list representation of the composite bitboard" do
      bitboard = BitBoard.new()

      assert [
               [1, 1, 1, 1, 1, 1, 1, 1],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [1, 1, 1, 1, 1, 1, 1, 1]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :composite))
    end

    test "returns an 8x8 representation of the bitboard for black pawns" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :black_pawns))
    end

    test "returns an 8x8 representation of the bitboard for black knights" do
      bitboard = BitBoard.new()

      assert [
               [0, 1, 0, 0, 0, 0, 1, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :black_knights))
    end

    test "returns an 8x8 representation of the bitboard for black rooks" do
      bitboard = BitBoard.new()

      assert [
               [1, 0, 0, 0, 0, 0, 0, 1],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :black_rooks))
    end

    test "returns an 8x8 representation of the bitboard for black bishops" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 1, 0, 0, 1, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :black_bishops))
    end

    test "returns an 8x8 representation of the bitboard for the black queen" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 1, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :black_queens))
    end

    test "returns an 8x8 representation of the bitboard for the black king" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 0, 1, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :black_king))
    end

    test "returns an 8x8 representation of the bitboard for white pawns" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :white_pawns))
    end

    test "returns an 8x8 representation of the bitboard for white knights" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 1, 0, 0, 0, 0, 1, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :white_knights))
    end

    test "returns an 8x8 representation of the bitboard for white rooks" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 0, 0, 0, 0, 0, 0, 1]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :white_rooks))
    end

    test "returns an 8x8 representation of the bitboard for white bishops" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 1, 0, 0, 1, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :white_bishops))
    end

    test "returns an 8x8 representation of the bitboard for the white queen" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 1, 0, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :white_queens))
    end

    test "returns an 8x8 representation of the bitboard for the white king" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 1, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :white_king))
    end

    test "returns an 8x8 representation of the bitboard for the black composite position" do
      bitboard = BitBoard.new()

      assert [
               [1, 1, 1, 1, 1, 1, 1, 1],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :black_composite))
    end

    test "returns an 8x8 representation of the bitboard for the white composite position" do
      bitboard = BitBoard.new()

      assert [
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [1, 1, 1, 1, 1, 1, 1, 1],
               [1, 1, 1, 1, 1, 1, 1, 1]
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :white_composite))
    end
  end
end
