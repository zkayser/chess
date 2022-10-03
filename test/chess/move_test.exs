defmodule Chess.MoveTest do
  use ExUnit.Case
  use ExUnitProperties

  import StreamData

  alias Chess.Move

  describe "changeset/1" do
    property "is valid when player is black or white, from is >= 0 and <= 63, and to is >= 0 and <= 63" do
      check(
        all(
          player <- one_of([constant("white"), constant("black")]),
          from <- integer(0..63),
          to <- filter(integer(0..63), fn index -> index != from end)
        )
      ) do
        assert Move.changeset(%{player: player, from: from, to: to}).valid?,
               "Expected move with player #{player} from #{from} to #{to} to be valid, but it was not"
      end
    end
  end
end
