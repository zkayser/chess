defmodule Chess.Test.BoardHelpers do
  @moduledoc """
  Test helpers for building Chess boards.
  """
  alias Chess.Board

  @doc """
  Helper for generating an empty board to facilitate testing.
  """
  @spec empty_board() :: Board.t()
  def empty_board do
    board = :array.new(size: 64, fixed: true, default: nil)
    %Board{board: board}
  end
end
