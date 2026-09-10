defmodule Chess.Moves.ProposalsTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Chess.Boards.Bitboards.Square
  alias Chess.Moves.Proposals

  describe "from_inputs/1" do
    property "returns an ok tuple with source and destination rank and file coordinates when inputs are valid " do
      check all(inputs <- input_generator()) do
        assert {:ok, %Proposals{}} = Proposals.from_inputs(inputs)
      end
    end

    test "returns an error tuple when source and destination are equal" do
      assert {:error, :source_and_destination_equal} =
               Proposals.from_inputs(%{source: "a1", destination: "a1"})
    end

    test "returns an error tuple when source or destination is an invalid rank/file combination" do
      inputs = %{source: "f9", destination: "z64"}
      assert {:error, {:invalid_inputs, inputs}} == Proposals.from_inputs(inputs)
    end
  end

  describe "masks/1" do
    test "converts source and destination coordinates to single-bit masks" do
      proposal = %Proposals{source: {"e", 1}, destination: {"e", 2}}

      assert {Square.mask({"e", 1}), Square.mask({"e", 2})} == Proposals.masks(proposal)
    end

    property "round-trips with Square.from_bitboard/1 for valid proposals" do
      check all(inputs <- input_generator()) do
        assert {:ok, proposal} = Proposals.from_inputs(inputs)
        {from_mask, to_mask} = Proposals.masks(proposal)

        assert Square.from_bitboard(from_mask) == proposal.source
        assert Square.from_bitboard(to_mask) == proposal.destination
      end
    end
  end

  def input_generator do
    gen all(
          source_file <- StreamData.string(?a..?h, min_length: 1, max_length: 1),
          source_rank <- StreamData.string(?1..?8, min_length: 1, max_length: 1),
          dest_file <- StreamData.string(?a..?h, min_length: 1, max_length: 1),
          dest_rank <- StreamData.string(?1..?8, min_length: 1, max_length: 1),
          {source_file, source_rank} != {dest_file, dest_rank}
        ) do
      %{source: "#{source_file}#{source_rank}", destination: "#{dest_file}#{dest_rank}"}
    end
  end
end
