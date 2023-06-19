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
end
