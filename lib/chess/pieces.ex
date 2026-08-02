defmodule Chess.Pieces do
  @moduledoc """
  Functions and types for defining and working with
  the different type of chess pieces.
  """
  alias Chess.Board.Coordinates
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
  alias Chess.BitBoards.Pieces.{Bishop, King, Knight, Pawn, Queen, Rook}
  alias Chess.Game

  @typedoc """
  Represents the individual piece modules themselves
  """
  @type piece() :: Bishop | King | Knight | Pawn | Queen | Rook

  @doc """
  Classifies the piece of the side to move occupying `source`.

  `source` may be a single-bit square mask (`Square.mask/1`) or a
  `{file, rank}` coordinate. Tuples are converted once at this boundary;
  classification itself uses mask intersection against each piece bitboard.

  Returns `{:ok, piece_module}` when occupied, or `{:error, :unoccupied}`.
  """
  @spec classify(Game.t(), Square.mask() | Coordinates.t()) ::
          {:ok, piece()} | {:error, :unoccupied}
  def classify(%Game{} = game, {file, rank}) when is_binary(file) and is_integer(rank) do
    classify(game, Square.mask({file, rank}))
  end

  def classify(%Game{} = game, source_mask) when is_integer(source_mask) do
    bitboards = BitBoard.get_boards_by_color(game.board, game.current_player)

    Enum.reduce_while(bitboards, {:error, :unoccupied}, fn {piece, bitboard}, _result ->
      if BitBoard.occupied?(bitboard, source_mask) do
        {:halt, {:ok, modularize(piece)}}
      else
        {:cont, {:error, :unoccupied}}
      end
    end)
  end

  @spec modularize(atom()) :: piece()
  defp modularize(:pawns), do: Pawn
  defp modularize(:bishops), do: Bishop
  defp modularize(:rooks), do: Rook
  defp modularize(:knights), do: Knight
  defp modularize(:queens), do: Queen
  defp modularize(:king), do: King
end
