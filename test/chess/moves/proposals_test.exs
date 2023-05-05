defmodule Chess.Moves.ProposalsTest do
  use ExUnit.Case
  use ExUnitProperties

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
