defmodule Chess.BitBoards.Pieces.King do
  @moduledoc """
  Functions for generating and validating king moves on a bitboard.
  """

  @behaviour Chess.Moves.Validator

  import Bitwise

  alias Chess.Bitboards.Move
  alias Chess.Bitboards.Slider
  alias Chess.Boards.BitBoard
  alias Chess.Boards.Bitboards.Square
  alias Chess.Game
  alias Chess.Moves.Proposals

  @knight_deltas [
    {1, 2},
    {2, 1},
    {-1, 2},
    {-2, 1},
    {1, -2},
    {2, -1},
    {-1, -2},
    {-2, -1}
  ]

  @king_deltas [
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, -1},
    {0, 1},
    {1, -1},
    {1, 0},
    {1, 1}
  ]

  @piece_types [:pawns, :rooks, :knights, :bishops, :queens, :king]

  @impl Chess.Moves.Validator
  @spec validate_move(Game.t(), Proposals.t()) :: {:ok, Move.t()} | {:error, atom()}
  def validate_move(game, %Proposals{source: source, destination: destination}) do
    with :ok <- validate_geometry(source, destination),
         :ok <- validate_not_self_capture(game, destination),
         :ok <- validate_king_safety(game, source, destination) do
      {:ok, %Move{from: source, to: destination, flag: move_flag(game, destination)}}
    end
  end

  @doc """
  Returns true if the king of the given color is under attack
  in the given board position.
  """
  @spec in_check?(BitBoard.t(), Chess.player()) :: boolean()
  def in_check?(board, color) do
    case king_square(board, color) do
      nil -> false
      square -> attacked_by?(board, opponent(color), square)
    end
  end

  defp validate_geometry(source, destination) do
    if king_step?(source, destination) do
      :ok
    else
      {:error, :invalid_geometry}
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
    board_after_move = apply_king_move(game.board, game.current_player, source, destination)

    if in_check?(board_after_move, game.current_player) do
      {:error, :king_in_check}
    else
      :ok
    end
  end

  defp move_flag(game, destination) do
    opponent = opponent(game.current_player)

    if occupied_by?(game.board, opponent, destination) do
      :captures
    else
      :quiet
    end
  end

  defp apply_king_move(board, color, from, to) do
    from_mask = Square.bitboard(from)
    to_mask = Square.bitboard(to)
    opponent = opponent(color)

    board
    |> clear_square(opponent, to_mask)
    |> move_piece(color, :king, from_mask, to_mask)
  end

  defp clear_square(board, color, square_mask) do
    Enum.reduce(@piece_types, board, fn piece_type, acc ->
      <<pieces::integer-size(64)>> = acc[{color, piece_type}]
      put_in(acc[{color, piece_type}], BitBoard.from_integer(pieces &&& bnot(square_mask)))
    end)
  end

  defp move_piece(board, color, piece_type, from_mask, to_mask) do
    <<pieces::integer-size(64)>> = board[{color, piece_type}]
    updated = (pieces &&& bnot(from_mask)) ||| to_mask
    put_in(board[{color, piece_type}], BitBoard.from_integer(updated))
  end

  defp king_square(board, color) do
    case BitBoard.get_raw(board, {color, :king}) do
      0 -> nil
      king_bits -> bit_to_square(king_bits)
    end
  end

  defp bit_to_square(bits) do
    bit_index = trailing_zeros(bits)
    rank = div(bit_index, 8) + 1
    file = Enum.at(~w(h g f e d c b a), rem(bit_index, 8))
    {file, rank}
  end

  defp trailing_zeros(n), do: trailing_zeros(n, 0)
  defp trailing_zeros(n, index) when (n &&& 1) == 1, do: index
  defp trailing_zeros(n, index), do: trailing_zeros(n >>> 1, index + 1)

  defp attacked_by?(board, attacker, square) do
    attacked_by_king?(board, attacker, square) or
      attacked_by_knight?(board, attacker, square) or
      attacked_by_pawn?(board, attacker, square) or
      attacked_by_slider?(board, attacker, square)
  end

  defp attacked_by_king?(board, attacker, square) do
    Enum.any?(@king_deltas, fn delta ->
      case offset_square(square, delta) do
        {:ok, origin} -> occupied_by_piece?(board, attacker, :king, origin)
        :error -> false
      end
    end)
  end

  defp attacked_by_knight?(board, attacker, square) do
    Enum.any?(@knight_deltas, fn delta ->
      case offset_square(square, delta) do
        {:ok, origin} -> occupied_by_piece?(board, attacker, :knights, origin)
        :error -> false
      end
    end)
  end

  defp attacked_by_pawn?(board, attacker, square) do
    pawn_origins(attacker, square)
    |> Enum.any?(fn origin -> occupied_by_piece?(board, attacker, :pawns, origin) end)
  end

  defp pawn_origins(:white, square) do
    # White pawns attack one rank forward diagonally, so they sit one rank below.
    for file_delta <- [-1, 1],
        {:ok, origin} <- [offset_square(square, {file_delta, -1})],
        do: origin
  end

  defp pawn_origins(:black, square) do
    for file_delta <- [-1, 1],
        {:ok, origin} <- [offset_square(square, {file_delta, 1})],
        do: origin
  end

  defp attacked_by_slider?(board, attacker, square) do
    occupied = BitBoard.get_raw(board, :full)

    Enum.any?(Slider.rook().deltas ++ Slider.bishop().deltas, fn delta ->
      case first_occupied_along(square, delta, occupied) do
        nil ->
          false

        blocker ->
          sliding_attacker?(board, attacker, blocker, delta)
      end
    end)
  end

  defp first_occupied_along(square, delta, occupied) do
    case offset_square(square, delta) do
      :error ->
        nil

      {:ok, next} ->
        if (Square.bitboard(next) &&& occupied) != 0 do
          next
        else
          first_occupied_along(next, delta, occupied)
        end
    end
  end

  defp sliding_attacker?(board, attacker, blocker, {file_delta, rank_delta}) do
    orthogonal? = file_delta == 0 or rank_delta == 0

    if orthogonal? do
      occupied_by_piece?(board, attacker, :rooks, blocker) or
        occupied_by_piece?(board, attacker, :queens, blocker)
    else
      occupied_by_piece?(board, attacker, :bishops, blocker) or
        occupied_by_piece?(board, attacker, :queens, blocker)
    end
  end

  defp occupied_by_piece?(board, color, piece_type, square) do
    pieces = BitBoard.get_raw(board, {color, piece_type})
    (pieces &&& Square.bitboard(square)) != 0
  end

  defp occupied_by?(board, color, square) do
    pieces = BitBoard.get_raw(board, color)
    (pieces &&& Square.bitboard(square)) != 0
  end

  defp opponent(:white), do: :black
  defp opponent(:black), do: :white

  defp king_step?({<<from_file>>, from_rank}, {<<to_file>>, to_rank}) do
    file_delta = abs(to_file - from_file)
    rank_delta = abs(to_rank - from_rank)

    file_delta <= 1 and rank_delta <= 1 and {file_delta, rank_delta} != {0, 0}
  end

  defp offset_square({<<file>>, rank}, {file_delta, rank_delta}) do
    case {<<file + file_delta>>, rank + rank_delta} do
      {<<new_file>>, new_rank} when new_file in ?a..?h and new_rank in 1..8 ->
        {:ok, {<<new_file>>, new_rank}}

      _ ->
        :error
    end
  end
end
