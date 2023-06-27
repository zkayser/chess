defmodule Chess.Bitboards.Slider do
  @moduledoc """
  Data structure presenting a base for
  sliding pieces.
  """

  defstruct [:deltas]

  @type delta() :: -1 | 0 | 1
  @type t() :: %__MODULE__{
          deltas: list({delta(), delta()})
        }

  @doc """
  Creates the slider deltas for a rook piece.
  """
  @spec rook() :: t()
  def rook, do: %__MODULE__{deltas: [{1, 0}, {0, -1}, {-1, 0}, {0, 1}]}

  @doc """
  Creates the slider deltas for a bishop piece.
  """
  @spec bishop() :: t()
  def bishop, do: %__MODULE__{deltas: [{1, 1}, {1, -1}, {-1, -1}, {-1, 1}]}
end
