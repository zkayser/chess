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
            current_player: Color.white(),
            en_passant_target: nil

  @type t() :: %__MODULE__{
          board: BitBoard.t(),
          move_list: list(Move.t()),
          current_player: Chess.player(),
          en_passant_target: Board.index() | nil
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
  alias Chess.Board.Coordinates
  alias Chess.Boards.BitBoard
  alias Chess.Move
  alias Chess.Moves.Proposals
  alias Chess.Pieces
  alias Chess.Players

  def play(game, proposal) do
    case Proposals.validate(game, proposal) do
      {:valid, move} -> {:ok, apply_move(game, move)}
      {:invalid, reason} -> {:error, {"Invalid move proposed", reason}}
    end
  end

  def apply_move(game, move) do
    new_board = BitBoard.update(game.board, move, game.current_player)

    # Handle en passant capture
    final_board =
      if is_en_passant_capture(game, move) do
        captured_pawn_index =
          if game.current_player == :white do
            game.en_passant_target + 8
          else
            game.en_passant_target - 8
          end

        opponent_color = Players.alternate(game.current_player)
        BitBoard.remove(new_board, captured_pawn_index, opponent_color)
      else
        new_board
      end

    en_passant_target = en_passant_target(game, move)

    %__MODULE__{
      board: final_board,
      move_list: [move | game.move_list],
      current_player: Players.alternate(game.current_player),
      en_passant_target: en_passant_target
    }
  end

  defp is_en_passant_capture(game, %Move{from: from, to: to}) do
    with {:ok, piece} <- Pieces.classify(game, Coordinates.index_to_coordinates(from)) do
      piece.type == Chess.Pieces.Pawn && to == game.en_passant_target
    else
      _ -> false
    end
  end

  defp en_passant_target(game, %Move{from: from, to: to}) do
    with {:ok, piece} <- Pieces.classify(game, from |> Coordinates.index_to_coordinates()) do
      if piece.type == Chess.Pieces.Pawn && abs(to - from) == 16 do
        (from + to) |> div(2)
      else
        nil
      end
    else
      _ -> nil
    end
  end
end
