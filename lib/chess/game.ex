defmodule Chess.Game do
  @moduledoc """
  A struct and related functions for working with a
  single chess game instance.
  """
  alias Chess.Boards.BitBoard
  alias Chess.Color
  alias Chess.Bitboards.Move

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
end
