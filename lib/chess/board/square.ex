defmodule Chess.Board.Square do
  @moduledoc """
  Representation of a square on a chess board.
  """
  import Integer, only: [is_even: 1]

  @type t() :: %__MODULE__{
    color: :white | :black
  }
  defstruct [:color]

  @spec init(non_neg_integer()) :: t()
  def init(index) when is_even(index) do
    %__MODULE__{color: :white}
  end
end
