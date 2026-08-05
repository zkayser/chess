defmodule Chess.BitBoards.Pieces.King do
  @moduledoc """
  King move validation (`Chess.Moves.Validator`).

  Orchestrates geometry, self-capture, king-safety, and castling checks.
  Castling geometry lives in `Chess.Bitboards.Castling`; attack detection
  lives in `Chess.Bitboards.Attacks`; candidate-move simulation lives on
  `Chess.Boards.BitBoard`. Castling rights are read from `Game` in O(1).
  """

  @behaviour Chess.Moves.Validator

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
    from_mask = Square.mask(source)
    to_mask = Square.mask(destination)

    with {:ok, move_type} <- classify_geometry(source, destination) do
      validate_typed_move(move_type, game, source, destination, from_mask, to_mask)
    end
  end

  @doc """
  Returns true if the side to move's king is under attack in `game`.

  Passes the king's bitboard mask straight to attack detection — no
  tuple round-trip via `Square.from_bitboard/1`.
  """
  @spec in_check?(Game.t()) :: boolean()
  def in_check?(%Game{} = game) do
    case BitBoard.get_raw(game.board, {game.current_player, :king}) do
      0 -> false
      king_mask -> Attacks.square_attacked_by?(game.board, Game.opponent(game), king_mask)
    end
  end

  # Geometry uses integer file/rank codepoints (`?a`..`?h`) and ranks —
  # not string file compares — then castling continues on masks.
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

  defp validate_typed_move(:step, game, source, destination, from_mask, to_mask) do
    with :ok <- validate_not_self_capture(game, to_mask),
         :ok <- validate_king_safety(game, from_mask, to_mask) do
      {:ok, Move.make(game, source, destination)}
    end
  end

  defp validate_typed_move(:castle, game, source, destination, from_mask, to_mask) do
    with {:ok, side} <- Castling.side(game.current_player, from_mask, to_mask),
         :ok <- validate_castling_rights(game, side),
         :ok <- validate_castling_path_clear(game, side),
         :ok <- validate_castling_safe(game, side) do
      {:ok, Move.make(game, source, destination, Castling.flag(side))}
    end
  end

  defp validate_not_self_capture(game, to_mask) do
    own_pieces = BitBoard.get_raw(game.board, game.current_player)

    if BitBoard.occupied?(own_pieces, to_mask) do
      {:error, :self_capture}
    else
      :ok
    end
  end

  defp validate_king_safety(game, from_mask, to_mask) do
    if game |> Game.apply_candidate_move(:king, from_mask, to_mask) |> in_check?() do
      {:error, :king_in_check}
    else
      :ok
    end
  end

  defp validate_castling_rights(game, side) do
    color = game.current_player
    rook_mask = Castling.rook_home(color, side)

    if Game.can_castle?(game, color, side) do
      require_rook_present(game.board, color, rook_mask)
    else
      {:error, :cannot_castle}
    end
  end

  defp require_rook_present(board, color, rook_mask) do
    rooks = BitBoard.get_raw(board, {color, :rooks})

    if BitBoard.occupied?(rooks, rook_mask) do
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
end
