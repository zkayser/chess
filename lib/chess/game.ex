defmodule Chess.Game do
  @moduledoc """
  A struct and related functions for working with a
  single chess game instance.
  """
  alias Chess.Bitboards.Move
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
  alias Chess.Color

  defstruct board: BitBoard.new(),
            move_list: [],
            current_player: Color.white()

  @type t() :: %__MODULE__{
          board: BitBoard.t(),
          move_list: list(Move.t()),
          current_player: Chess.player()
        }

  @doc """
  Creates a new Game instance.
  """
  def new, do: %__MODULE__{}

  @doc """
  Returns the opposing side to the game's current player.
  """
  @spec opponent(t()) :: Chess.player()
  def opponent(%__MODULE__{current_player: :white}), do: :black
  def opponent(%__MODULE__{current_player: :black}), do: :white

  @doc """
  Applies a candidate move for validation / king-safety simulation.

  Clears any opponent piece on the destination square, then moves the given
  piece for the side to move from `from_mask` to `to_mask`. Both arguments
  are single-bit integer masks (`Square.mask/1` / `Square.mask_from_index/1`).
  Convert from `{file, rank}` once at the caller (e.g. validator entry), not
  inside simulation loops.

  Returns a game with the updated board only — move list, side to move,
  castling rights, en passant, etc. are left unchanged.
  """
  @spec apply_candidate_move(t(), atom(), Square.mask(), Square.mask()) :: t()
  def apply_candidate_move(
        %__MODULE__{board: board, current_player: color} = game,
        piece_type,
        from_mask,
        to_mask
      )
      when is_integer(from_mask) and is_integer(to_mask) do
    updated_board =
      board
      |> BitBoard.clear_square(opponent(game), to_mask)
      |> BitBoard.move_piece(color, piece_type, from_mask, to_mask)

    %{game | board: updated_board}
  end

  ##########################################
  # Tentative interface for game play here #
  # Let's start implementing the Proposals #
  # module and see how this goes.          #
  ##########################################
  # def play(game, proposal) do
  #   case Proposals.validate(game, proposal) do
  #     {:valid, move_type} -> {:ok, apply_move(game, proposal, move_type)}
  #     {:invalid, reason} -> {:error, {"Invalid move proposed", reason}}
  #   end
  # end

  # defp apply_move(game, proposal, move_type) do
  #   move = Proposals.accept(proposal, move_type)

  #   %__MODULE__{
  #     board: BitBoard.update(game.board, move),
  #     move_list: [move | game.move_list],
  #     current_player: Players.alternate(game.player)
  #   }
  # end
end
