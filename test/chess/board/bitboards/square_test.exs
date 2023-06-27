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

  describe "bitboard/1" do
    squares =
      for rank <- 1..8, file <- ?h..?a do
        {<<file>>, rank}
      end

    for {square, index} <- Enum.with_index(squares) do
      test "returns the bitboard representation of #{inspect(square)}" do
        assert Square.bitboard(unquote(square)) == 1 <<< unquote(index)
      end
    end
  end
end
