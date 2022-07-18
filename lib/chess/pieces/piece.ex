defmodule Chess.Piece do
  @moduledoc """
  Representation of a chess piece and associated
  functions.
  """
  alias Chess.Board
  alias Chess.Pieces.{Bishop, King, Knight, Pawn, Queen, Rook}

  @type t() ::
          %__MODULE__{
            type: type(),
            color: color(),
            moves: list(non_neg_integer())
          }
          | nil
  @type type() :: Pawn | Rook | Knight | Bishop | Queen | King
  @opaque color() :: :white | :black

  defstruct type: nil,
            color: nil,
            moves: MapSet.new()

  # Starting Positions
  @pawn_indices Enum.concat(8..15, 48..55)
  @rook_indices [0, 7, 56, 63]
  @knight_indices [1, 6, 57, 62]
  @bishop_indices [2, 5, 58, 61]
  @queen_indices [3, 59]
  @king_indices [4, 60]
  @empty_indices 16..47

  @doc """
  Given a starting index, returns the piece that is placed
  at that index.

  iex> Chess.Piece.for_starting_position(0)
  %Chess.Piece{type: Chess.Pieces.Rook, color: :black}
  """
  @spec for_starting_position(Board.index()) :: t()
  def for_starting_position(index) when index in @empty_indices, do: nil

  def for_starting_position(index) do
    %__MODULE__{
      type: type_at_starting_position(index),
      color: if(index in 0..15, do: :black, else: :white)
    }
  end

  @callback potential_moves(t(), Board.index(), Board.t()) :: MapSet.t(Board.index())

  @doc """
  Returns a set of squares that a piece could potentially
  move to.
  """
  @spec potential_moves(t(), starting_position :: Board.index(), Board.t()) ::
          MapSet.t(Board.index())
  def potential_moves(%__MODULE__{type: type_module} = piece, starting_position, board) do
    type_module.potential_moves(piece, starting_position, board)
  end

  @spec type_at_starting_position(Board.index()) :: type()
  defp type_at_starting_position(index) do
    case index do
      i when i in @pawn_indices -> Pawn
      i when i in @rook_indices -> Rook
      i when i in @knight_indices -> Knight
      i when i in @bishop_indices -> Bishop
      i when i in @queen_indices -> Queen
      i when i in @king_indices -> King
    end
  end

  defimpl String.Chars do
    alias Chess.Piece
    alias Chess.Pieces.{Bishop, King, Knight, Pawn, Queen, Rook}

    def to_string(%Piece{type: Pawn}), do: " ♟️ "
    def to_string(%Piece{type: Rook}), do: " ♜ "
    def to_string(%Piece{type: Knight}), do: " ♞ "
    def to_string(%Piece{type: Bishop}), do: " ♝ "
    def to_string(%Piece{type: Queen}), do: " ♛ "
    def to_string(%Piece{type: King}), do: " ♚ "
  end

  defimpl Inspect do
    import Inspect.Algebra
    alias Chess.Piece

    @black "\e[1;40;37m"
    @white "\e[1;47;37m"

    def inspect(%Piece{color: :white} = piece, _opts) do
      color(string(to_string(piece)), :binary, Inspect.Opts.new(syntax_colors: [binary: @white]))
    end

    def inspect(%Piece{color: :black} = piece, _opts) do
      color(string(to_string(piece)), :binary, Inspect.Opts.new(syntax_colors: [binary: @black]))
    end
  end
end
