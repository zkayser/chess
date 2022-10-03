defmodule Chess.Move do
  @moduledoc """
  Exposes an embedded schema representing a
  chess move.
  """
  use Ecto.Schema

  alias Chess.Board
  alias Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :player, Ecto.Enum, values: [:white, :black]
    field :from, :integer
    field :to, :integer
  end

  @type t() :: %__MODULE__{
          player: :white | :black,
          from: non_neg_integer(),
          to: non_neg_integer()
        }

  @spec changeset(map()) :: Changeset.t(t())
  def changeset(attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, [:player, :from, :to])
    |> Changeset.validate_inclusion(:from, Board.bounds())
    |> Changeset.validate_inclusion(:to, Board.bounds())
    |> then(fn changeset ->
      if changeset.changes[:from] == changeset.changes[:to] do
        Changeset.add_error(changeset, :to, "value '%{to}' must be different from '%{from}'",
          to: changeset.changes[:to],
          from: changeset.changes[:from]
        )
      else
        changeset
      end
    end)
  end
end
