defmodule Chess.Pieces.MoveCache do
  @moduledoc """
  A Nebulex-based cache for caching lists of potential moves per
  piece given a starting index or coordinate
  """

  use Nebulex.Cache, otp_app: :chess, adapter: Nebulex.Adapters.Local
end
