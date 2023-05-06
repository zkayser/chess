defmodule Chess.Pieces do
  @moduledoc """
  Functions and types for defining and working with
  the different type of chess pieces.
  """
  alias Chess.Board.Coordinates
  alias Chess.Boards.BitBoard
  alias Chess.BitBoards.Pieces.{Bishop, King, Knight, Pawn, Queen, Rook}
  alias Chess.Game

  @typedoc """
  Represents the individual piece modules themselves
  """
  @type piece() :: Bishop | King | Knight | Pawn | Queen | Rook

  @doc """
  Takes in a game and a source position (given as a `{file, rank}` tuple)
  and returns the piece module for the piece that is present at the given
  source position.

  If the source position is not occupied, returns an error tuple instead.
  """
  @spec classify(Game.t(), Coordinates.t()) :: {:ok, piece()} | {:error, :unoccupied}
  def classify(%Game{} = game, source_coordinates) do
    bitboards = BitBoard.get_boards_by_color(game.board, game.current_player)

    Enum.reduce_while(bitboards, {:error, :unoccupied}, fn {piece, bitboard}, _result ->
      if BitBoard.square_occupied?(bitboard, source_coordinates) do
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
