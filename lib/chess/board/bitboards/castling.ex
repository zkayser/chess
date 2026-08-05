defmodule Chess.Bitboards.Castling do
  @moduledoc """
  Static castling geometry for bitboard move validation.

  Owns king/rook home masks, king destination masks, path masks (squares that
  must be empty), and transit masks (squares that must be unattacked).
  Consumers compose these masks with occupancy or attack bitboards via
  bitwise AND rather than iterating coordinates.

  Coordinate tuples are retained only as compile-time source data for mask
  generation and documentation; the public API returns and accepts
  `Square.mask()` values on the hot path.
  """

  import Bitwise

  alias Chess.Boards.Bitboards.Square
  alias Chess.Color

  @type side() :: :kingside | :queenside

  # Tuple constants — source data for compile-time mask generation / docs.
  @king_home_squares %{
    white: {"e", 1},
    black: {"e", 8}
  }

  @king_destination_squares %{
    {:white, :kingside} => {"g", 1},
    {:white, :queenside} => {"c", 1},
    {:black, :kingside} => {"g", 8},
    {:black, :queenside} => {"c", 8}
  }

  @rook_home_squares %{
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

  @king_home_masks Map.new(@king_home_squares, fn {color, square} ->
                     {color, Square.mask(square)}
                   end)

  @king_destination_masks Map.new(@king_destination_squares, fn {key, square} ->
                            {key, Square.mask(square)}
                          end)

  @rook_home_masks Map.new(@rook_home_squares, fn {key, square} ->
                     {key, Square.mask(square)}
                   end)

  @path_masks Map.new(@path_squares, fn {key, squares} ->
                {key, squares |> Enum.map(&Square.mask/1) |> Enum.reduce(0, &bor/2)}
              end)

  @transit_masks Map.new(@transit_squares, fn {key, squares} ->
                   {key, squares |> Enum.map(&Square.mask/1) |> Enum.reduce(0, &bor/2)}
                 end)

  @doc """
  Returns the king's starting square mask for `color`.
  """
  @spec king_home(Color.t()) :: Square.mask()
  def king_home(color), do: Map.fetch!(@king_home_masks, color)

  @doc """
  Returns the rook's starting square mask for `color` and castling `side`.
  """
  @spec rook_home(Color.t(), side()) :: Square.mask()
  def rook_home(color, side), do: Map.fetch!(@rook_home_masks, {color, side})

  @doc """
  Returns the king's destination square mask for `color` and castling `side`.
  """
  @spec king_destination(Color.t(), side()) :: Square.mask()
  def king_destination(color, side), do: Map.fetch!(@king_destination_masks, {color, side})

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
  Bitboard mask of squares the king occupies, passes through, or lands on
  while castling — none may be attacked.
  """
  @spec transit_mask(Color.t(), side()) :: integer()
  def transit_mask(color, side), do: Map.fetch!(@transit_masks, {color, side})

  @doc """
  Classifies a king move from `source_mask` to `destination_mask` as kingside
  or queenside castling for `color`.

  Both arguments are single-bit `Square.mask()` values — convert from
  `{file, rank}` once at the validator boundary.
  """
  @spec side(Color.t(), Square.mask(), Square.mask()) ::
          {:ok, side()} | {:error, :cannot_castle}
  def side(color, source_mask, destination_mask)
      when is_integer(source_mask) and is_integer(destination_mask) do
    home = king_home(color)
    kingside = king_destination(color, :kingside)
    queenside = king_destination(color, :queenside)

    case {source_mask, destination_mask} do
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
