defmodule Chess.Pieces do
  @moduledoc """
  Functions and types for defining and working with
  the different type of chess pieces.
  """
  import Bitwise

  alias Chess.BitBoards.Pieces.{Bishop, King, Knight, Pawn, Queen, Rook}
  alias Chess.Game
  alias Chess.Moves.Proposals

  @typedoc """
  Represents the individual piece modules themselves
  """
  @type piece() :: Bishop | King | Knight | Pawn | Queen | Rook

  # This allows us to go from right to left with files, as is standard
  # in chess representations, but keep the bit indexes in the order
  # we'll find them in the binary bitboard representations, which is
  # going to be from 0 to 7, going from right to left across the file
  # from file h to file a.
  # This is used to create a bit mask that allows us to determine if
  # a position is occupied on the bitboard, and by which piece type.
  @file_masks Map.new(Enum.with_index(~w(h g f e d c b a)))

  @doc """
  Takes in a game and a source position (given as a `{file, rank}` tuple)
  and returns the piece module for the piece that is present at the given
  source position.

  If the source position is not occupied, returns an error tuple instead.
  """
  @spec classify(Game.t(), Proposals.coordinates()) :: {:ok, piece()} | {:error, :unoccupied}
  def classify(game, {file, rank} = _source) do
    bitboards = Map.get(game.board, game.current_player)

    Enum.reduce_while(bitboards, :unoccupied, fn {piece, <<bitboard::integer-size(64)>>},
                                                 _result ->
      rank_shift = (rank - 1) * 8
      file_shift = @file_masks[file]
      bitmask = 1 <<< (file_shift + rank_shift)

      if (bitmask &&& bitboard) != 0 do
        {:halt, {:ok, modularize(piece)}}
      else
        {:cont, {:error, :unoccupied}}
      end
    end)
  end

  @spec modularize(atom()) :: module()
  defp modularize(:pawns), do: Pawn
  defp modularize(:bishops), do: Bishop
  defp modularize(:rooks), do: Rook
  defp modularize(:knights), do: Knight
  defp modularize(:queens), do: Queen
  defp modularize(:king), do: King
end
