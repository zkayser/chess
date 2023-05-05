defmodule Chess.PiecesTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.BitBoards.Pieces.{Bishop, King, Knight, Pawn, Queen, Rook}
  alias Chess.Game
  alias Chess.Pieces

  @rank_1_mappings %{
    {"a", 1} => Rook,
    {"b", 1} => Knight,
    {"c", 1} => Bishop,
    {"d", 1} => Queen,
    {"e", 1} => King,
    {"f", 1} => Bishop,
    {"g", 1} => Knight,
    {"h", 1} => Rook
  }
  @rank_2_mappings Map.new(Enum.map(?a..?h, fn file -> {{<<file>>, 2}, Pawn} end))
  @rank_7_mappings Map.new(Enum.map(?a..?h, fn file -> {{<<file>>, 7}, Pawn} end))
  @rank_8_mappings Map.new(
                     Enum.map(@rank_1_mappings, fn {{file, rank}, piece} -> {{file, 8}, piece} end)
                   )

  @coordinate_to_piece_mappings @rank_1_mappings
                                |> Map.merge(@rank_2_mappings)
                                |> Map.merge(@rank_7_mappings)
                                |> Map.merge(@rank_8_mappings)

  describe "classify/1" do
    for white_rank <- [1, 2], file <- ?a..?h do
      test "returns an ok tuple with the correct piece type for white starting coordinates at #{<<file>>}#{white_rank}" do
        game = Game.new()
        source_coordinate = {<<unquote(file)>>, unquote(white_rank)}

        assert {:ok, piece} = Pieces.classify(game, source_coordinate)

        assert piece == @coordinate_to_piece_mappings[{<<unquote(file)>>, unquote(white_rank)}]
      end
    end

    for black_rank <- [1, 2], file <- ?a..?h do
      test "returns an ok tuple with the correct piece type for black starting coordinates at #{<<file>>}#{black_rank}" do
        game = Game.new()
        source_coordinate = {<<unquote(file)>>, unquote(black_rank)}

        assert {:ok, piece} = Pieces.classify(game, source_coordinate)

        assert piece == @coordinate_to_piece_mappings[{<<unquote(file)>>, unquote(black_rank)}]
      end
    end

    property "returns {:error, :unoccupied} for blank squares" do
      check all(unoccupied_coordinates <- unoccupied_coordinate_generator()) do
        assert {:error, :unoccupied} = Pieces.classify(Game.new(), unoccupied_coordinates)
      end
    end
  end

  def unoccupied_coordinate_generator do
    gen all(
          file <- StreamData.string(?a..?h, min_length: 1, max_length: 1),
          rank <- StreamData.integer(3..6)
        ) do
      {file, rank}
    end
  end
end
