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
end
