# Knight Move Validation Plan

**Module:** `Chess.BitBoards.Pieces.Knight`
**Behaviour:** `Chess.Moves.Validator`
**File:** `lib/chess/board/bitboards/pieces/knight.ex`
**Test:** `test/chess/board/bitboards/pieces/knight_test.exs`

## Overview

The Knight moves in an L-shape: two squares in one axis and one square in the
perpendicular axis. It is the only piece that jumps over other pieces — path
obstruction is irrelevant. Validation reduces to geometry + self-capture +
king safety.

## Validation steps

1. **Geometry check:** Compute file delta and rank delta between source and
   destination. The move is valid if the `{abs(file_delta), abs(rank_delta)}`
   pair is in `[{1, 2}, {2, 1}]`. Otherwise return `{:error, :invalid_geometry}`.
2. **Self-capture check:** Destination must not be occupied by own piece.
   Return `{:error, :self_capture}`.
3. **King safety check:** Simulate the move on the bitboard and verify the
   own king is not in check. Return `{:error, :king_in_check}`.
4. **Determine flag:**
   - Destination occupied by opponent → `:captures`
   - Otherwise → `:quiet`
5. **Return** `{:ok, %Move{from: source, to: destination, flag: flag}}`

## Test cases

### Test 1: Knight quiet move — center of board

```elixir
# Board state: White knight on d4, no other pieces nearby.
# Move: d4 -> f5 (2 right, 1 up)
# Expected: {:ok, %Move{from: {"d", 4}, to: {"f", 5}, flag: :quiet}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   | . |   |   | . |   |   |  <- other valid destinations
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   | * |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   | N |   |   |   |   |  <- white knight
#   +---+---+---+---+---+---+---+---+
# 3 |   |   | . |   |   | . |   |   |  <- other valid destinations
#   +---+---+---+---+---+---+---+---+
# 2 |   | . |   |   |   |   | . |   |  <- other valid destinations
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 2: Knight capture

```elixir
# Board state: White knight on d4, black pawn on e6.
# Move: d4 -> e6 (1 right, 2 up — captures pawn)
# Expected: {:ok, %Move{from: {"d", 4}, to: {"e", 6}, flag: :captures}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   | p |   |   |   |  <- black pawn (capture target)
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   | N |   |   |   |   |  <- white knight
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 3: Knight self-capture rejected

```elixir
# Board state: White knight on d4, white pawn on f5.
# Move: d4 -> f5
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
# 5 |   |   |   |   |   | P |   |   |  <- own pawn blocks
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   | N |   |   |   |   |  <- white knight
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 4: Invalid geometry — diagonal move

```elixir
# Board state: White knight on d4.
# Move: d4 -> e5 (1 right, 1 up — diagonal, not L-shape)
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
# 5 |   |   |   |   | X |   |   |   |  <- invalid (diagonal)
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   | N |   |   |   |   |  <- white knight
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 5: Knight jump over pieces

```elixir
# Board state: White knight on b1, surrounded by white pawns on a2, b2, c2,
#              and pieces on a1, c1. Knight can still reach a3 and c3.
# Move: b1 -> c3 (jumps over pawn wall)
# Expected: {:ok, %Move{from: {"b", 1}, to: {"c", 3}, flag: :quiet}}
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
# 3 |   |   | * |   |   |   |   |   |  <- destination (jumps over pawns)
#   +---+---+---+---+---+---+---+---+
# 2 | P | P | P |   |   |   |   |   |  <- pawn wall — doesn't block knight
#   +---+---+---+---+---+---+---+---+
# 1 | R | N | B |   |   |   |   |   |  <- knight surrounded
#   +---+---+---+---+---+---+---+---+
```

### Test 6: Knight from corner — limited destinations

```elixir
# Board state: White knight on a1.
# Move: a1 -> b3 (only 2 valid destinations from a1: b3, c2)
# Expected: {:ok, %Move{from: {"a", 1}, to: {"b", 3}, flag: :quiet}}
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
# 3 |   | * |   |   |   |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 2 |   |   | . |   |   |   |   |   |  <- other valid destination
#   +---+---+---+---+---+---+---+---+
# 1 | N |   |   |   |   |   |   |   |  <- knight in corner
#   +---+---+---+---+---+---+---+---+
```

### Test 7: Knight pinned to king — king in check after move

```elixir
# Board state: White king on e1, white knight on e2, black rook on e8.
#              Knight is pinned — moving it exposes king to rook.
# Move: e2 -> f4
# Expected: {:error, :king_in_check}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   | r |   |   |   |  <- black rook pins knight
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   | X |   |   |  <- destination, but knight is pinned
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   | N |   |   |   |  <- white knight (pinned)
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   | K |   |   |   |  <- white king
#   +---+---+---+---+---+---+---+---+
```

## Implementation notes

- The 8 knight deltas (as file, rank offsets) are:
  `[{-2,-1},{-2,1},{-1,-2},{-1,2},{1,-2},{1,2},{2,-1},{2,1}]`
- No need to iterate paths or use `Slider` — geometry check is purely
  arithmetic on the file/rank deltas.
- Coordinate arithmetic: subtract ASCII values of file chars for file delta,
  subtract rank integers for rank delta.
- Use `Square.try_delta/2` from source to verify the destination is reachable
  and on the board in one step, or compute deltas directly.
