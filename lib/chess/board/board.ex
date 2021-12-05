defmodule Chess.Board do
  @moduledoc """
  Representation of a chess board.
  """
  @behaviour Access

  alias Chess.Board.Square

  @type t :: %__MODULE__{
          board: :array.array(Square.t())
        }
  @opaque board :: :array.array(Square.t())
  @type index :: non_neg_integer()

  defstruct [:board]

  @bounds 0..63

  @spec layout() :: t()
  def layout do
    board = :array.new(size: 64, fixed: true, default: :empty)
    %__MODULE__{board: :array.map(fn index, _ -> Square.init(index) end, board)}
  end

  @spec bounds() :: Range.t(0, 63)
  def bounds, do: @bounds

  @spec in_bounds?(integer()) :: boolean()
  def in_bounds?(index), do: index in @bounds

  @spec square_at(t(), index()) :: Square.t()
  def square_at(%__MODULE__{board: board}, index), do: :array.get(index, board)

  @impl Access
  @spec fetch(t(), index()) :: {:ok, Square.t()} | :error
  def fetch(board, index) when index in @bounds do
    {:ok, square_at(board, index)}
  end

  def fetch(_board, _index), do: :error

  @impl Access
  @spec get_and_update(t(), index(), (Square.t() -> {Square.t(), Square.t()})) ::
          {Square.t(), t()}
  def get_and_update(board, index, function) do
    {current_square, new_square} = function.(board[index])

    new_board =
      :array.set(
        index,
        new_square,
        board.board
      )

    {current_square, %__MODULE__{board: new_board}}
  end

  @impl Access
  @spec pop(t(), index()) :: {Square.t(), t()}
  def pop(board, index) when index in @bounds do
    {square_at(board, index), board}
  end

  def pop(board, _index), do: {nil, board}
end
