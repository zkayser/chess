defmodule Chess.Moves.Proposals do
  @moduledoc """
  This module deals with validating proposed chess moves given
  the state of a game, and exposes functions for converting
  proposed moves into concrete moves.
  """

  # alias Chess.Bitboards.Move
  # alias Chess.Game

  @valid_file_range ?a..?h
  @valid_rank_range ?1..?8

  defstruct source: nil,
            destination: nil

  @type coordinates() :: {file :: String.t(), rank :: integer()}

  @typedoc """
  An `input_string` is a 16-bit (2-byte) string
  containing a rank and file, where each takes up
  1 byte (8 bits each, 16 bits total)
  """
  @type input_string() :: <<_::16>>

  @typedoc """
  A map of inputs contains a source and destination input string,
  representing the move being proposed.
  """
  @type inputs() :: %{
          source: input_string(),
          destination: input_string()
        }
  @type t() :: %__MODULE__{source: coordinates(), destination: coordinates()}

  @doc """
  Takes in a map of inputs representing a proposed move to be made, and converts the
  raw input representation (presumably passed from user-land) into a valid `__MODULE__.t()`
  struct if the inputs are valid.
  """
  @spec from_inputs(inputs() | any()) ::
          {:ok, t()}
          | {:error, {:invalid_inputs, term()}}
          | {:error, :source_and_destination_equal}
  def from_inputs(%{source: source, destination: destination}) when source == destination,
    do: {:error, :source_and_destination_equal}

  def from_inputs(%{
        source: <<source_file::8, source_rank::8>>,
        destination: <<dest_file::8, dest_rank::8>>
      })
      when source_file in @valid_file_range and source_rank in @valid_rank_range and
             dest_file in @valid_file_range and dest_rank in @valid_rank_range do
    {:ok,
     %__MODULE__{
       source: {<<source_file>>, String.to_integer(<<source_rank>>)},
       destination: {<<dest_file>>, String.to_integer(<<dest_rank>>)}
     }}
  end

  def from_inputs(inputs), do: {:error, {:invalid_inputs, inputs}}

  #######################################################
  # Just templating this for now as I think through how #
  # to make this interface work nicely.                 #
  #######################################################
  alias Chess.Game
  alias Chess.Move
  alias Chess.Pieces

  @spec validate(Game.t(), t() | inputs()) :: {:valid, Move.t()} | {:invalid, reason}
        when reason: any()
  def validate(game, %__MODULE__{} = proposal) do
    with {:ok, piece} <- Pieces.classify(game, proposal.source),
         {:ok, move} <- piece.type.validate_move(game, proposal) do
      {:valid, move}
    else
      {:error, reason} -> {:invalid, reason}
    end
  end

  def validate(game, %{source: _, destination: _} = inputs) do
    case from_inputs(inputs) do
      {:ok, proposal} -> validate(game, proposal)
      {:error, reason} -> {:invalid, reason}
    end
  end
end
