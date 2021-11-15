defmodule Chess.Board do
  @moduledoc """
  Representation of a chess board.
  """
  alias Chess.Board.Square

  @type t :: :array.array(Square.t())

  @spec layout() :: t()
  def layout do
    board = :array.new(size: 64, fixed: true, default: :empty)
    :array.map(fn index, _ -> Square.init(index) end, board)
  end
end
