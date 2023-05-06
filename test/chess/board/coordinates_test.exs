defmodule Chess.Board.CoordinatesTest do
  use ExUnit.Case

  alias Chess.Board.Coordinates

  describe "file_bit_index/1" do
    for {file, index} <- Enum.with_index(~w(h g f e d c b a)) do
      test "returns index #{index} for file #{file}" do
        assert unquote(index) == Coordinates.file_bit_index(unquote(file))
      end
    end
  end
end
