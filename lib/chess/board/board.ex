defmodule Chess.Board do
  @moduledoc """
  Representation of a chess board.
  """

  @type t :: :array.array(term())

  @spec layout() :: t()
  def layout do
    :array.new(size: 64, fixed: true, default: :empty)
  end
end
