defmodule Chess.Color do
  @moduledoc """
  Simple module containing types and functions unifying the
  black and white colors.
  """

  @type t() :: :white | :black

  def white, do: :white
  def black, do: :black
end
