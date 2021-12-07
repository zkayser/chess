defmodule Chess.Test.BoardHelpers do
  alias Chess.Board
  alias Chess.Board.Square

  @doc """
  Helper for generating an empty board to facilitate testing.
  """
  @spec empty_board() :: Board.t()
  def empty_board do
    board = :array.new(size: 64, fixed: true, default: %Square{})
    %Board{board: board}
  end
end
