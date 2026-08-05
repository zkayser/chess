defmodule Chess.Game.CastlingRightsTest do
  use ExUnit.Case, async: true

  alias Chess.Game.CastlingRights

  describe "new/0" do
    test "both sides are available" do
      rights = CastlingRights.new()

      assert CastlingRights.available?(rights, :kingside)
      assert CastlingRights.available?(rights, :queenside)
    end
  end

  describe "revoke/2" do
    test "revoking the king clears both sides" do
      rights = CastlingRights.new() |> CastlingRights.revoke(:king)

      refute CastlingRights.available?(rights, :kingside)
      refute CastlingRights.available?(rights, :queenside)
    end

    test "revoking kingside leaves queenside" do
      rights = CastlingRights.new() |> CastlingRights.revoke(:kingside)

      refute CastlingRights.available?(rights, :kingside)
      assert CastlingRights.available?(rights, :queenside)
    end

    test "revoking queenside leaves kingside" do
      rights = CastlingRights.new() |> CastlingRights.revoke(:queenside)

      assert CastlingRights.available?(rights, :kingside)
      refute CastlingRights.available?(rights, :queenside)
    end
  end
end
