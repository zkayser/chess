defmodule Chess.Boards.Bitboards.SquareTest do
  use ExUnit.Case
  use ExUnitProperties

  import Bitwise

  alias Chess.Boards.Bitboards.Square

  describe "try_delta/2" do
    property "when file is between b and g and rank between 2 and 7, all delta applications are valid" do
      check all(
              file <- StreamData.string(?b..?g, min_length: 1, max_length: 1),
              rank <- StreamData.integer(2..7),
              file_delta <- StreamData.integer(-1..1),
              rank_delta <- StreamData.integer(-1..1)
            ) do
        assert {:ok, {<<new_file>>, new_rank}} =
                 Square.try_delta({file, rank}, {file_delta, rank_delta})

        assert new_file in ?a..?h
        assert new_rank in 1..8
      end
    end

    test "returns error when file delta is -1 and the current file is a" do
      assert :error = Square.try_delta({"a", 1}, {-1, 0})
    end

    test "returns error when file delta is positive 1 and current file is h" do
      assert :error = Square.try_delta({"h", 1}, {1, 0})
    end

    test "returns error when rank is 1 and rank delta is negative 1" do
      assert :error = Square.try_delta({"a", 1}, {0, -1})
    end

    test "returns error when rank is 8 and rank delta is positive 1" do
      assert :error = Square.try_delta({"a", 8}, {0, 1})
    end
  end

  describe "to_index/1 and from_index/1" do
    squares =
      for rank <- 1..8, file <- ?h..?a//-1 do
        {<<file>>, rank}
      end

    for {square, index} <- Enum.with_index(squares) do
      test "round-trips #{inspect(square)} through index #{index}" do
        assert Square.to_index(unquote(square)) == unquote(index)
        assert Square.from_index(unquote(index)) == unquote(square)
        assert Square.from_index(Square.to_index(unquote(square))) == unquote(square)
      end
    end

    test "maps corner and center squares to known indices" do
      assert Square.to_index({"h", 1}) == 0
      assert Square.to_index({"a", 1}) == 7
      assert Square.to_index({"h", 8}) == 56
      assert Square.to_index({"a", 8}) == 63
      assert Square.to_index({"e", 1}) == 3
      assert Square.to_index({"e", 4}) == 27
    end
  end

  describe "mask_from_index/1 and mask/1" do
    squares =
      for rank <- 1..8, file <- ?h..?a//-1 do
        {<<file>>, rank}
      end

    for {square, index} <- Enum.with_index(squares) do
      test "mask_from_index/1 sets only bit #{index} for #{inspect(square)}" do
        assert Square.mask_from_index(unquote(index)) == 1 <<< unquote(index)
      end

      test "mask/1 matches mask_from_index/1 for #{inspect(square)}" do
        assert Square.mask(unquote(square)) == Square.mask_from_index(unquote(index))
        assert Square.mask(unquote(square)) == Square.bitboard(unquote(square))
      end
    end
  end

  describe "bitboard/1" do
    squares =
      for rank <- 1..8, file <- ?h..?a//-1 do
        {<<file>>, rank}
      end

    for {square, index} <- Enum.with_index(squares) do
      test "returns the bitboard representation of #{inspect(square)}" do
        assert Square.bitboard(unquote(square)) == 1 <<< unquote(index)
      end
    end
  end

  describe "from_bitboard/1" do
    test "returns nil when no bits are set" do
      assert Square.from_bitboard(0) == nil
    end

    squares =
      for rank <- 1..8, file <- ?h..?a//-1 do
        {<<file>>, rank}
      end

    for {square, index} <- Enum.with_index(squares) do
      test "round-trips #{inspect(square)} through bitboard/1" do
        assert Square.from_bitboard(1 <<< unquote(index)) == unquote(square)
        assert Square.from_bitboard(Square.bitboard(unquote(square))) == unquote(square)
      end
    end

    test "returns the least-significant set bit when multiple bits are set" do
      assert Square.from_bitboard(Square.bitboard({"h", 1}) ||| Square.bitboard({"a", 8})) ==
               {"h", 1}
    end
  end
end
