defmodule Chess.Board.CoordinatesTest do
  use ExUnit.Case

  alias Chess.Board.Coordinates

  @coordinates for file <- ?h..?a, rank <- 1..8, do: {<<file>>, rank}

  describe "to_bitboard/1" do
    for coordinate <- @coordinates do
      test "returns the bitboard representation for coordinate #{inspect(coordinate)}" do
        assert result = Coordinates.to_bitboard(unquote(coordinate))
        assert 1 = result |> Integer.digits(2) |> Enum.filter(&(&1 == 1)) |> Enum.count()
      end
    end
  end

  describe "file_bit_index/1" do
    for {file, index} <- Enum.with_index(~w(h g f e d c b a)) do
      test "returns index #{index} for file #{file}" do
        assert unquote(index) == Coordinates.file_bit_index(unquote(file))
      end
    end
  end
end
