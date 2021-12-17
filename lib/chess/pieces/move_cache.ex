defmodule Chess.Pieces.MoveCache do
  use Nebulex.Cache, otp_app: :chess, adapter: Nebulex.Adapters.Local
end
