defmodule Chess.Game do
  @moduledoc """
  A struct and related functions for working with a
  single chess game instance.
  """
  alias Chess.Bitboards.Move
  alias Chess.Boards.BitBoard
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
