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

    test "is invalid when player is neither black nor white" do
      refute Move.changeset(%{player: "invalid", from: 0, to: 1}).valid?,
             "Expected changeset to be invalid when player is not either `white` or `black`, but it was marked as valid"
    end

    property "is invalid when from is outside of the range 0..63" do
      check(all(from <- one_of([integer(-100..-1), integer(64..100)]))) do
        refute Move.changeset(%{player: "white", from: from, to: 1}).valid?,
               "Expected changeset to be invalid when from is outside the range of 0..63, but it was marked valid with from = #{from}"
      end
    end

    property "is invalid when to is outside of the range 0..63" do
      check(all(to <- one_of([integer(-100..-1), integer(64..100)]))) do
        refute Move.changeset(%{player: "white", from: 1, to: to}).valid?,
               "Expected changeset to be invalid when to is outside the range of 0..63, but it was marked valid with to = #{to}"
      end
    end

    test "is invalid when to and from are equal" do
      refute Move.changeset(%{player: "white", from: 2, to: 2}).valid?,
             "Expected changeset to be invalid when to is equal to from, but it was marked valid with both values equal"
    end
  end
end
