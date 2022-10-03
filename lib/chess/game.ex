defmodule Chess.Game do
  @moduledoc """
  A struct representing the state of a chess game
  and functions for operating on the game instance.
  """
  alias Chess.Board

  defstruct board: Board.layout(),
            active_player: :white

  @type t() :: %__MODULE__{
          board: Board.t(),
          active_player: :white | :black
        }

  @doc """
  Initializes a new game instance.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{}
  end
end
