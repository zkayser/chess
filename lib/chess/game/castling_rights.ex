defmodule Chess.Game.CastlingRights do
  @moduledoc """
  Per-color castling availability for a side.

  Both kingside and queenside start available. Rights are cleared when the
  king moves (both sides), when the corresponding rook moves, or when that
  rook is captured — callers update via `revoke/2`. Validators read these
  flags in constant time instead of scanning `Game.move_list`.
  """

  @type side() :: :kingside | :queenside
  @type revoke_target() :: :king | side()

  @type t() :: %__MODULE__{
          kingside: boolean(),
          queenside: boolean()
        }

  defstruct kingside: true, queenside: true

  @doc """
  Returns full castling rights (both sides available).
  """
  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc """
  Returns rights with neither side available.
  """
  @spec none() :: t()
  def none, do: %__MODULE__{kingside: false, queenside: false}

  @doc """
  Returns true when castling on `side` is still allowed.
  """
  @spec available?(t(), side()) :: boolean()
  def available?(%__MODULE__{kingside: kingside}, :kingside), do: kingside
  def available?(%__MODULE__{queenside: queenside}, :queenside), do: queenside

  @doc """
  Clears castling rights for a revoke target.

  Revoking `:king` clears both sides; revoking `:kingside` or `:queenside`
  clears only that side.
  """
  @spec revoke(t(), revoke_target()) :: t()
  def revoke(%__MODULE__{}, :king), do: none()
  def revoke(%__MODULE__{} = rights, :kingside), do: %{rights | kingside: false}
  def revoke(%__MODULE__{} = rights, :queenside), do: %{rights | queenside: false}
end
