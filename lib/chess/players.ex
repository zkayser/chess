defmodule Chess.Players do
  @moduledoc """
  This module contains functions for working with players.
  """

  alias Chess.Color

  @spec alternate(Color.t()) :: Color.t()
  def alternate(color) do
    case color do
      :white -> :black
      :black -> :white
    end
  end
end
