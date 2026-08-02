defmodule Chess.BitBoards.Pieces.King do
  @moduledoc """
  King move validation (`Chess.Moves.Validator`).

  Orchestrates geometry, self-capture, king-safety, and castling checks.
  Castling geometry lives in `Chess.Bitboards.Castling`; attack detection
  lives in `Chess.Bitboards.Attacks`; candidate-move simulation lives on
  `Chess.Boards.BitBoard`.
  """

  @behaviour Chess.Moves.Validator

  import Bitwise

  alias Chess.Bitboards.Attacks
  alias Chess.Bitboards.Castling
  alias Chess.Bitboards.Move
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
  alias Chess.Game
  alias Chess.Moves.Proposals

  @impl Chess.Moves.Validator
  @spec validate_move(Game.t(), Proposals.t()) :: {:ok, Move.t()} | {:error, atom()}
  def validate_move(game, %Proposals{source: source, destination: destination}) do
    with {:ok, move_type} <- classify_geometry(source, destination) do
      validate_typed_move(move_type, game, source, destination)
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

  defp classify_geometry({<<from_file>>, from_rank}, {<<to_file>>, to_rank}) do
    file_delta = abs(to_file - from_file)
    rank_delta = abs(to_rank - from_rank)

    case {file_delta, rank_delta} do
      {0, 0} -> {:error, :invalid_geometry}
      {file, rank} when file <= 1 and rank <= 1 -> {:ok, :step}
      {2, 0} -> {:ok, :castle}
      _ -> {:error, :invalid_geometry}
    end
  end

  defp validate_typed_move(:step, game, source, destination) do
    with :ok <- validate_not_self_capture(game, destination),
         :ok <- validate_king_safety(game, source, destination) do
      {:ok, Move.make(game, source, destination)}
    end
  end

  defp validate_typed_move(:castle, game, source, destination) do
    with {:ok, side} <- Castling.side(game.current_player, source, destination),
         :ok <- validate_castling_rights(game, side),
         :ok <- validate_castling_path_clear(game, side),
         :ok <- validate_castling_safe(game, side) do
      {:ok, Move.make(game, source, destination, Castling.flag(side))}
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

  defp validate_castling_rights(game, side) do
    color = game.current_player
    rook_square = Castling.rook_home(color, side)

    with :ok <- require_unmoved(game.move_list, Castling.king_home(color)),
         :ok <- require_unmoved(game.move_list, rook_square) do
      require_rook_present(game.board, color, rook_square)
    end
  end

  defp require_unmoved(move_list, square) do
    if piece_has_moved?(move_list, square) do
      {:error, :cannot_castle}
    else
      :ok
    end
  end

  defp require_rook_present(board, color, square) do
    rooks = BitBoard.get_raw(board, {color, :rooks})

    if (rooks &&& Square.bitboard(square)) != 0 do
      :ok
    else
      {:error, :cannot_castle}
    end
  end

  defp validate_castling_path_clear(game, side) do
    occupied = BitBoard.get_raw(game.board, :full)

    if Castling.path_clear?(occupied, game.current_player, side) do
      :ok
    else
      {:error, :cannot_castle}
    end
  end

  defp validate_castling_safe(game, side) do
    mask = Castling.transit_mask(game.current_player, side)

    if Attacks.mask_attacked_by?(game.board, Game.opponent(game), mask) do
      {:error, :cannot_castle}
    else
      :ok
    end
  end

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
end
