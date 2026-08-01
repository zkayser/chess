defmodule Chess.BitBoards.Pieces.King do
  @moduledoc """
  King move validation (`Chess.Moves.Validator`).

  Orchestrates geometry, self-capture, king-safety, and castling checks.
  Attack detection lives in `Chess.Bitboards.Attacks`; candidate-move
  simulation lives on `Chess.Boards.BitBoard`.
  """

  @behaviour Chess.Moves.Validator

  alias Chess.Bitboards.Attacks
  alias Chess.Bitboards.Move
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
  alias Chess.Game
  alias Chess.Moves.Proposals

  @impl Chess.Moves.Validator
  @spec validate_move(Game.t(), Proposals.t()) :: {:ok, Move.t()} | {:error, atom()}
  def validate_move(game, %Proposals{source: source, destination: destination}) do
    cond do
      king_step?(source, destination) ->
        validate_king_step(game, source, destination)

      castling_geometry?(source, destination) ->
        validate_castling(game, source, destination)

      true ->
        {:error, :invalid_geometry}
    end
  end

  @doc """
  Returns true if the side to move's king is under attack in `game`.
  """
  @spec in_check?(Game.t()) :: boolean()
  def in_check?(%Game{} = game) do
    case king_square(game.board, game.current_player) do
      nil -> false
      square -> Attacks.square_attacked_by?(game.board, Game.opponent(game), square)
    end
  end

  defp validate_king_step(game, source, destination) do
    with :ok <- validate_not_self_capture(game, destination),
         :ok <- validate_king_safety(game, source, destination) do
      {:ok, Move.make(game, source, destination)}
    end
  end

  defp validate_castling(game, source, destination) do
    with {:ok, side} <- castling_side(game.current_player, source, destination),
         :ok <- validate_castling_rights(game, side),
         :ok <- validate_castling_path_clear(game, side),
         :ok <- validate_castling_safe(game, side) do
      {:ok, Move.make(game, source, destination, castling_flag(side))}
    end
  end

  defp validate_not_self_capture(game, destination) do
    if occupied_by?(game.board, game.current_player, destination) do
      {:error, :self_capture}
    else
      :ok
    end
  end

  defp validate_king_safety(game, source, destination) do
    if game |> Game.apply_candidate_move(:king, source, destination) |> in_check?() do
      {:error, :king_in_check}
    else
      :ok
    end
  end

  defp castling_side(color, source, destination) do
    case {source, destination, king_home(color)} do
      {home, to, home} ->
        case {to, kingside_destination(color), queenside_destination(color)} do
          {kingside, kingside, _} -> {:ok, :kingside}
          {queenside, _, queenside} -> {:ok, :queenside}
          _ -> {:error, :cannot_castle}
        end

      _ ->
        {:error, :cannot_castle}
    end
  end

  defp validate_castling_rights(game, side) do
    color = game.current_player
    rook_square = rook_home(color, side)

    cond do
      piece_has_moved?(game.move_list, king_home(color)) ->
        {:error, :cannot_castle}

      piece_has_moved?(game.move_list, rook_square) ->
        {:error, :cannot_castle}

      not rook_on_square?(game.board, color, rook_square) ->
        {:error, :cannot_castle}

      true ->
        :ok
    end
  end

  defp rook_on_square?(board, color, square) do
    board
    |> BitBoard.get({color, :rooks})
    |> BitBoard.square_occupied?(square)
  end

  defp validate_castling_path_clear(game, side) do
    occupied = BitBoard.get(game.board, :full)

    if Enum.any?(
         path_squares(game.current_player, side),
         &BitBoard.square_occupied?(occupied, &1)
       ) do
      {:error, :cannot_castle}
    else
      :ok
    end
  end

  defp validate_castling_safe(game, side) do
    opponent = Game.opponent(game)
    squares = transit_squares(game.current_player, side)

    if Enum.any?(squares, &Attacks.square_attacked_by?(game.board, opponent, &1)) do
      {:error, :cannot_castle}
    else
      :ok
    end
  end

  defp castling_flag(:kingside), do: :king_castle
  defp castling_flag(:queenside), do: :queen_castle

  defp king_home(:white), do: {"e", 1}
  defp king_home(:black), do: {"e", 8}

  defp kingside_destination(:white), do: {"g", 1}
  defp kingside_destination(:black), do: {"g", 8}

  defp queenside_destination(:white), do: {"c", 1}
  defp queenside_destination(:black), do: {"c", 8}

  defp rook_home(:white, :kingside), do: {"h", 1}
  defp rook_home(:white, :queenside), do: {"a", 1}
  defp rook_home(:black, :kingside), do: {"h", 8}
  defp rook_home(:black, :queenside), do: {"a", 8}

  # Squares that must be empty between king and rook (includes destination).
  defp path_squares(:white, :kingside), do: [{"f", 1}, {"g", 1}]
  defp path_squares(:white, :queenside), do: [{"b", 1}, {"c", 1}, {"d", 1}]
  defp path_squares(:black, :kingside), do: [{"f", 8}, {"g", 8}]
  defp path_squares(:black, :queenside), do: [{"b", 8}, {"c", 8}, {"d", 8}]

  # King start, pass-through, and landing squares — none may be attacked.
  defp transit_squares(:white, :kingside), do: [{"e", 1}, {"f", 1}, {"g", 1}]
  defp transit_squares(:white, :queenside), do: [{"e", 1}, {"d", 1}, {"c", 1}]
  defp transit_squares(:black, :kingside), do: [{"e", 8}, {"f", 8}, {"g", 8}]
  defp transit_squares(:black, :queenside), do: [{"e", 8}, {"d", 8}, {"c", 8}]

  defp piece_has_moved?(move_list, square) do
    Enum.any?(move_list, fn %Move{from: from} -> from == square end)
  end

  defp king_square(board, color) do
    board
    |> BitBoard.get_raw({color, :king})
    |> Square.from_bitboard()
  end

  defp occupied_by?(board, color, square) do
    board
    |> BitBoard.get(color)
    |> BitBoard.square_occupied?(square)
  end

  defp king_step?({<<from_file>>, from_rank}, {<<to_file>>, to_rank}) do
    file_delta = abs(to_file - from_file)
    rank_delta = abs(to_rank - from_rank)

    file_delta <= 1 and rank_delta <= 1 and {file_delta, rank_delta} != {0, 0}
  end

  defp castling_geometry?({<<from_file>>, from_rank}, {<<to_file>>, to_rank}) do
    from_rank == to_rank and abs(to_file - from_file) == 2
  end
end
