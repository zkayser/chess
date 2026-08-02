defmodule Chess.Bitboards.Castling do
  @moduledoc """
  Static castling geometry for bitboard move validation.

  Owns king/rook home squares, king destinations, and the path masks of
  squares that must be empty between king and rook. Consumers compose
  these masks with occupancy bitboards via bitwise AND rather than
  iterating coordinates.
  """

  import Bitwise

  alias Chess.Boards.Bitboards.Square
  alias Chess.Color

  @type side() :: :kingside | :queenside

  @king_homes %{
    white: {"e", 1},
    black: {"e", 8}
  }

  @king_destinations %{
    {:white, :kingside} => {"g", 1},
    {:white, :queenside} => {"c", 1},
    {:black, :kingside} => {"g", 8},
    {:black, :queenside} => {"c", 8}
  }

  @rook_homes %{
    {:white, :kingside} => {"h", 1},
    {:white, :queenside} => {"a", 1},
    {:black, :kingside} => {"h", 8},
    {:black, :queenside} => {"a", 8}
  }

  # Squares between king and rook that must be empty (includes king destination).
  @path_squares %{
    {:white, :kingside} => [{"f", 1}, {"g", 1}],
    {:white, :queenside} => [{"b", 1}, {"c", 1}, {"d", 1}],
    {:black, :kingside} => [{"f", 8}, {"g", 8}],
    {:black, :queenside} => [{"b", 8}, {"c", 8}, {"d", 8}]
  }

  # King start, pass-through, and landing squares — none may be attacked.
  @transit_squares %{
    {:white, :kingside} => [{"e", 1}, {"f", 1}, {"g", 1}],
    {:white, :queenside} => [{"e", 1}, {"d", 1}, {"c", 1}],
    {:black, :kingside} => [{"e", 8}, {"f", 8}, {"g", 8}],
    {:black, :queenside} => [{"e", 8}, {"d", 8}, {"c", 8}]
  }

  @path_masks Map.new(@path_squares, fn {key, squares} ->
                {key, squares |> Enum.map(&Square.bitboard/1) |> Enum.reduce(0, &bor/2)}
              end)

  @doc """
  Returns the king's starting square for `color`.
  """
  @spec king_home(Color.t()) :: Square.t()
  def king_home(color), do: Map.fetch!(@king_homes, color)

  @doc """
  Returns the rook's starting square for `color` and castling `side`.
  """
  @spec rook_home(Color.t(), side()) :: Square.t()
  def rook_home(color, side), do: Map.fetch!(@rook_homes, {color, side})

  @doc """
  Returns the king's destination square for `color` and castling `side`.
  """
  @spec king_destination(Color.t(), side()) :: Square.t()
  def king_destination(color, side), do: Map.fetch!(@king_destinations, {color, side})

  @doc """
  Bitboard mask of squares that must be empty for `color` to castle `side`.
  """
  @spec path_mask(Color.t(), side()) :: integer()
  def path_mask(color, side), do: Map.fetch!(@path_masks, {color, side})

  @doc """
  Returns true when `occupied` (raw full-board bitboard) has no pieces on the
  castling path for `color` and `side`.
  """
  @spec path_clear?(integer(), Color.t(), side()) :: boolean()
  def path_clear?(occupied, color, side) when is_integer(occupied) do
    (occupied &&& path_mask(color, side)) == 0
  end

  @doc """
  Squares the king occupies, passes through, or lands on while castling.
  """
  @spec transit_squares(Color.t(), side()) :: list(Square.t())
  def transit_squares(color, side), do: Map.fetch!(@transit_squares, {color, side})

  @doc """
  Classifies a king move from `source` to `destination` as kingside or
  queenside castling for `color`.
  """
  @spec side(Color.t(), Square.t(), Square.t()) :: {:ok, side()} | {:error, :cannot_castle}
  def side(color, source, destination) do
    home = king_home(color)
    kingside = king_destination(color, :kingside)
    queenside = king_destination(color, :queenside)

    case {source, destination} do
      {^home, ^kingside} -> {:ok, :kingside}
      {^home, ^queenside} -> {:ok, :queenside}
      _ -> {:error, :cannot_castle}
    end
  end

  @doc """
  Move flag for a successful castle on `side`.
  """
  @spec flag(side()) :: :king_castle | :queen_castle
  def flag(:kingside), do: :king_castle
  def flag(:queenside), do: :queen_castle
end
