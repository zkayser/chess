defmodule Chess.Board do
  @moduledoc """
  Representation of a chess board.
  """
  @behaviour Access

  alias Chess.Move
  alias Chess.Piece

  @opaque board :: :array.array(Piece.t())
  @type t :: %__MODULE__{
          grid: board()
        }
  @type index :: non_neg_integer()
  @type coordinates :: {non_neg_integer(), non_neg_integer()}

  defstruct [:grid]

  @bounds 0..63
  @column_and_row_to_index Enum.reduce(@bounds, %{}, fn index, lookups ->
                             Map.put(lookups, {rem(index, 8) + 1, div(index, 8) + 1}, index)
                           end)
  @index_to_column_and_row Enum.reduce(@bounds, %{}, fn index, lookups ->
                             Map.put(lookups, index, {rem(index, 8) + 1, div(index, 8) + 1})
                           end)

  @spec layout() :: t()
  def layout do
    board = :array.new(size: 64, fixed: true, default: nil)
    %__MODULE__{grid: :array.map(fn index, _ -> Piece.for_starting_position(index) end, board)}
  end

  @spec apply_move(t(), Move.t()) :: t()
  def apply_move(%__MODULE__{grid: starting_grid} = board, move) do
    grid = :array.set(move.from, nil, starting_grid)
    %__MODULE__{board | grid: :array.set(move.to, board[move.from], grid)}
  end

  @spec bounds() :: Range.t(0, 63)
  def bounds, do: @bounds

  @spec in_bounds?(integer()) :: boolean()
  def in_bounds?(index), do: index in @bounds

  @spec square_at(t(), index()) :: Piece.t()
  def square_at(%__MODULE__{grid: board}, index), do: :array.get(index, board)

  @spec index_to_coordinates(index()) :: coordinates()
  def index_to_coordinates(index) when index in @bounds,
    do: Map.get(@index_to_column_and_row, index)

  @spec coordinates_to_index(coordinates()) :: index()
  def coordinates_to_index(coordinates) do
    Map.get(@column_and_row_to_index, coordinates)
  end

  @impl Access
  @spec fetch(t(), index()) :: {:ok, Piece.t()} | :error
  def fetch(board, index) when index in @bounds do
    {:ok, square_at(board, index)}
  end

  def fetch(board, {column, row}) when column < 9 and column > 0 and row < 9 and row > 0 do
    index = Map.get(@column_and_row_to_index, {column, row})
    {:ok, square_at(board, index)}
  end

  def fetch(_board, _index), do: :error

  @impl Access
  @spec get_and_update(t(), index(), (Piece.t() -> {Piece.t(), Piece.t()})) ::
          {Piece.t(), t()}
  def get_and_update(%__MODULE__{grid: grid} = board, index, function) do
    {current_piece, new_piece} = function.(board[index])

    new_grid =
      :array.set(
        index,
        new_piece,
        grid
      )

    {current_piece, %__MODULE__{grid: new_grid}}
  end

  @impl Access
  @spec pop(t(), index()) :: {Piece.t(), t()}
  def pop(board, index) when index in @bounds do
    {square_at(board, index), board}
  end

  def pop(board, _index), do: {nil, board}
end
