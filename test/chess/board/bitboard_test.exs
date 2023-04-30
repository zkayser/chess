defmodule Chess.Boards.BitBoardTest do
  use ExUnit.Case, async: true

  alias Chess.Boards.BitBoard

  describe "new/0" do
    test "creates a BitBoard struct" do
      assert %BitBoard{} = bitboard = BitBoard.new()

      bitboard
      |> Map.from_struct()
      |> Map.values()
      |> Enum.flat_map(&Map.values/1)
      |> Enum.each(fn board ->
        assert match?(<<_::integer-size(64)>>, board),
               "Expected a 64-bit integer wrapped as a bytestring to represent bitboard state. Got: #{inspect(board)}"
      end)
    end
  end

  describe "accessors/0" do
    test "returns the list of all bitboard types" do
      pieces_by_color =
        for color <- ~w(white black)a, piece <- ~w(pawns knights rooks bishops queens king)a do
          {color, piece}
        end

      composites = ~w(full white black)a

      expected_type_set = MapSet.new(Enum.concat(pieces_by_color, composites))

      actual_set = MapSet.new(BitBoard.accessors())

      assert MapSet.equal?(actual_set, expected_type_set), """
      Expected set of Bitboard types to equal expected set.
      Actual: #{inspect(actual_set)}
      Expected: #{inspect(expected_type_set)}
      """
    end
  end

  describe "get/2" do
    for bitboard_type <- BitBoard.accessors() do
      test "returns bitboard when given #{inspect(bitboard_type)}" do
        bitboard = BitBoard.new()
        full_row = 0b11111111

        expected_full_composite = <<full_row, full_row, 0, 0, 0, 0, full_row, full_row>>
        expected_white_composite = <<0, 0, 0, 0, 0, 0, full_row, full_row>>
        expected_black_composite = <<full_row, full_row, 0, 0, 0, 0, 0, 0>>

        case unquote(bitboard_type) do
          {color, piece_type} ->
            assert get_in(Map.from_struct(bitboard), [color, piece_type]) ==
                     BitBoard.get(bitboard, unquote(bitboard_type))

          :full ->
            assert BitBoard.get(bitboard, unquote(bitboard_type)) ==
                     expected_full_composite

          :white ->
            assert BitBoard.get(bitboard, unquote(bitboard_type)) == expected_white_composite

          :black ->
            assert BitBoard.get(bitboard, unquote(bitboard_type)) == expected_black_composite
        end
      end
    end
  end

  describe "get_raw/2" do
    test "returns the integer-encoded value of the bitboard representation" do
      bitboard = BitBoard.new()

      assert 0b1111111100000000 = BitBoard.get_raw(bitboard, {:white, :pawns})
    end
  end

  describe "from_integer/1" do
    test "returns the bitstring representation of an integer value" do
      assert <<0, 0, 0, 0, 0, 0, 255, 255>> = BitBoard.from_integer(0b1111111111111111)
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :full))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:black, :pawns}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:black, :knights}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:black, :rooks}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:black, :bishops}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:black, :queens}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:black, :king}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:white, :pawns}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:white, :knights}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:white, :rooks}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:white, :bishops}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:white, :queens}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, {:white, :king}))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :black))
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
             ] == BitBoard.to_grid(BitBoard.get(bitboard, :white))
    end
  end
end
