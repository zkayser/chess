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

    test "populates square indices and masks once at the proposal boundary" do
      assert {:ok, proposal} = Proposals.from_inputs(%{source: "e1", destination: "e2"})

      assert proposal.source == {"e", 1}
      assert proposal.destination == {"e", 2}
      assert proposal.source_index == Square.to_index({"e", 1})
      assert proposal.destination_index == Square.to_index({"e", 2})
      assert proposal.source_mask == Square.mask_from_index(proposal.source_index)
      assert proposal.destination_mask == Square.mask_from_index(proposal.destination_index)
    end

    property "derived masks match Square.mask/1 for every valid input" do
      check all(inputs <- input_generator()) do
        assert {:ok, proposal} = Proposals.from_inputs(inputs)

        assert proposal.source_mask == Square.mask(proposal.source)
        assert proposal.destination_mask == Square.mask(proposal.destination)
        assert proposal.source_index == Square.to_index(proposal.source)
        assert proposal.destination_index == Square.to_index(proposal.destination)
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

  describe "from_coordinates/2" do
    test "builds a proposal with human coordinates plus indices and masks" do
      proposal = Proposals.from_coordinates({"e", 1}, {"g", 1})

      assert %Proposals{
               source: {"e", 1},
               destination: {"g", 1},
               source_index: source_index,
               destination_index: destination_index,
               source_mask: source_mask,
               destination_mask: destination_mask
             } = proposal

      assert source_index == Square.to_index({"e", 1})
      assert destination_index == Square.to_index({"g", 1})
      assert source_mask == Square.mask_from_index(source_index)
      assert destination_mask == Square.mask_from_index(destination_index)
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
