defmodule Chess.Board.Square do
  @moduledoc """
  Representation of a square on a chess board.
  """
  import Integer, only: [is_even: 1]

  @type t() :: %__MODULE__{
    color: color()
  }
  @opaque color :: :white | :black

  defstruct [:color]

  @spec init(non_neg_integer()) :: t()
  def init(index) do
    %__MODULE__{color: color_for(index)}
  end

  @spec color_for(index :: non_neg_integer()) :: color()
  defp color_for(index) when is_even(index), do: :white
  defp color_for(_index), do: :black
end
