defmodule Chess.Game do
  @moduledoc """
  A struct representing the state of a chess game
  and functions for operating on the game instance.
  """
  alias Chess.Board
  alias Chess.Move
  alias Chess.Piece

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

  @spec play(t(), Move.attributes()) ::
          {:ok, t()} | {:error, Ecto.Changeset.t(Move.t()) | String.t()}
  def play(%__MODULE__{board: board} = game, move) do
    with %{valid?: true} = changeset <- Move.changeset(move),
         %Move{} = move <- Ecto.Changeset.apply_changes(changeset),
         :player_matches <-
           if(move.player == game.active_player, do: :player_matches, else: :player_mismatch),
         true <- Enum.member?(Piece.potential_moves(board[move.from], move.from, board), move.to) do
      grid = :array.set(move.to, board[move.from], board.grid)
      grid = :array.set(move.from, nil, grid)

      {:ok,
       %__MODULE__{
         game
         | board: %Board{game.board | grid: grid},
           active_player: if(game.active_player == :white, do: :black, else: :white)
       }}
    else
      %Ecto.Changeset{} = changeset ->
        {:error, changeset}

      :player_mismatch ->
        {:error,
         "Player mismatch: Active Player #{inspect(game.active_player)}\nMoving player: #{move.player}"}

      _ ->
        {:error, "Invalid move -- From: #{move.from} to #{move.to} for player #{move.player}"}
    end
  end
end
