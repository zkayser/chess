defmodule Chess.Moves.Proposals do
  @moduledoc """
  This module deals with validating proposed chess moves given
  the state of a game, and exposes functions for converting
  proposed moves into concrete moves.
  """

  @valid_file_range ?a..?h
  @valid_rank_range ?1..?8

  defstruct source: nil,
            destination: nil

  @opaque coordinates() :: {file :: String.t(), rank :: integer()}
  @type t() :: %__MODULE__{source: coordinates(), destination: coordinates()}

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
end
