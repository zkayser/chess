defmodule Chess.Board do
  @moduledoc """
  Representation of a chess board.
  """
  alias Chess.Board.Square

  @type t :: :array.array(Square.t())

  @bounds 0..63

  @spec layout() :: t()
  def layout do
    board = :array.new(size: 64, fixed: true, default: :empty)
    :array.map(fn index, _ -> Square.init(index) end, board)
  end

  @spec bounds() :: Range.t(0, 63)
  def bounds, do: @bounds

  @spec in_bounds?(integer()) :: boolean()
  def in_bounds?(index), do: index in @bounds
end
