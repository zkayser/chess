# Queen Move Validation Plan

**Module:** `Chess.BitBoards.Pieces.Queen`
**Behaviour:** `Chess.Moves.Validator`
**File:** `lib/chess/board/bitboards/pieces/queen.ex`
**Test:** `test/chess/board/bitboards/pieces/queen_test.exs`

## Overview

The Queen combines Rook and Bishop movement — it slides any number of squares
along ranks, files, or diagonals. Since Rook and Bishop validation will already
be implemented, the Queen's geometry check accepts either pattern. Path clearance
logic is identical.

## Validation steps

1. **Geometry check:** The move must be either:
   - Straight (same file or same rank) — rook-like, OR
   - Diagonal (`abs(file_delta) == abs(rank_delta)`, both non-zero) — bishop-like
   - If neither, return `{:error, :invalid_geometry}`.
2. **Self-capture check:** Destination must not be occupied by own piece.
   Return `{:error, :self_capture}`.
3. **Path clearance:** Same as Rook (for straight moves) or Bishop (for diagonal
   moves). If any intermediate square is occupied, return `{:error, :path_blocked}`.
4. **King safety check:** Simulate the move, verify own king not in check.
   Return `{:error, :king_in_check}`.
5. **Determine flag:**
   - Destination occupied by opponent → `:captures`
   - Otherwise → `:quiet`
6. **Return** `{:ok, %Move{from: source, to: destination, flag: flag}}`

## Test cases

### Test 1: Queen straight move — vertical (rook-like)

```elixir
# Board state: White queen on d1, path clear.
# Move: d1 -> d5 (4 squares up along d-file)
# Expected: {:ok, %Move{from: {"d", 1}, to: {"d", 5}, flag: :quiet}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   | * |   |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   | . |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   | . |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   | . |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   | Q |   |   |   |   |  <- white queen
#   +---+---+---+---+---+---+---+---+
```

### Test 2: Queen straight move — horizontal (rook-like)

```elixir
# Board state: White queen on d4, path clear.
# Move: d4 -> a4 (3 squares left along rank 4)
# Expected: {:ok, %Move{from: {"d", 4}, to: {"a", 4}, flag: :quiet}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 | * | . | . | Q |   |   |   |   |  <- queen slides left to a4
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 3: Queen diagonal move (bishop-like)

```elixir
# Board state: White queen on d1, path clear.
# Move: d1 -> g4 (3 squares NE diagonal)
# Expected: {:ok, %Move{from: {"d", 1}, to: {"g", 4}, flag: :quiet}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   | * |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   | . |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   | . |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   | Q |   |   |   |   |  <- white queen
#   +---+---+---+---+---+---+---+---+
```

### Test 4: Queen capture — diagonal

```elixir
# Board state: White queen on d1, black rook on g4, path clear.
# Move: d1 -> g4 (captures rook)
# Expected: {:ok, %Move{from: {"d", 1}, to: {"g", 4}, flag: :captures}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   | r |   |  <- black rook (capture target)
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   | . |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   | . |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   | Q |   |   |   |   |  <- white queen
#   +---+---+---+---+---+---+---+---+
```

### Test 5: Path blocked — vertical

```elixir
# Board state: White queen on d1, white pawn on d3, target d5.
# Move: d1 -> d5
# Expected: {:error, :path_blocked}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   | X |   |   |   |   |  <- can't reach
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   | P |   |   |   |   |  <- own pawn blocks path
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   | . |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   | Q |   |   |   |   |  <- white queen
#   +---+---+---+---+---+---+---+---+
```

### Test 6: Path blocked — diagonal

```elixir
# Board state: White queen on d1, black pawn on e2, target f3.
# Move: d1 -> f3
# Expected: {:error, :path_blocked}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   | X |   |   |  <- can't reach
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   | p |   |   |   |  <- opponent pawn blocks diagonal
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   | Q |   |   |   |   |  <- white queen
#   +---+---+---+---+---+---+---+---+
```

### Test 7: Invalid geometry — knight-like move

```elixir
# Board state: White queen on d1.
# Move: d1 -> e3 (1 right, 2 up — L-shape, not queen movement)
# Expected: {:error, :invalid_geometry}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   | X |   |   |   |  <- invalid (L-shape)
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   | Q |   |   |   |   |  <- white queen
#   +---+---+---+---+---+---+---+---+
```

### Test 8: Self-capture rejected

```elixir
# Board state: White queen on d1, white bishop on d4.
# Move: d1 -> d4
# Expected: {:error, :self_capture}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   | B |   |   |   |   |  <- own bishop blocks
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   | . |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   | . |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   | Q |   |   |   |   |  <- white queen
#   +---+---+---+---+---+---+---+---+
```

### Test 9: Queen move one square — vertical

```elixir
# Board state: White queen on d4.
# Move: d4 -> d5
# Expected: {:ok, %Move{from: {"d", 4}, to: {"d", 5}, flag: :quiet}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   | * |   |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   | Q |   |   |   |   |  <- white queen
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

## Implementation notes

- The geometry check is the union of Rook and Bishop geometry:
  - Rook-like: `file_delta == 0 or rank_delta == 0` (but not both)
  - Bishop-like: `abs(file_delta) == abs(rank_delta)` (both non-zero)
- Path clearance is identical to whichever geometry matched.
- Consider delegating to shared sliding helpers that Rook and Bishop also use,
  rather than duplicating path iteration code.
- Direction delta `{sign(file_delta), sign(rank_delta)}` will match one of the
  8 combined deltas from `Slider.rook/0 ++ Slider.bishop/0`.
