defmodule Chess.Board do
  @moduledoc """
  Representation of a chess board.
  """
  alias Chess.Board.Square

  @opaque t :: :array.array(Square.t())
  @type index :: non_neg_integer()

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

  @spec square_at(t(), index()) :: Square.t()
  def square_at(board, index), do: :array.get(index, board)
end
