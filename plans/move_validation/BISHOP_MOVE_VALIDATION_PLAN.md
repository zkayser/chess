# Bishop Move Validation Plan

**Module:** `Chess.BitBoards.Pieces.Bishop`
**Behaviour:** `Chess.Moves.Validator`
**File:** `lib/chess/board/bitboards/pieces/bishop.ex`
**Test:** `test/chess/board/bitboards/pieces/bishop_test.exs`

## Overview

The Bishop slides any number of squares diagonally. It cannot jump over pieces.
The path clearance logic mirrors the Rook but uses diagonal deltas from
`Slider.bishop/0`.

## Validation steps

1. **Geometry check:** The move must be purely diagonal — `abs(file_delta)`
   must equal `abs(rank_delta)`, and neither can be 0. Otherwise return
   `{:error, :invalid_geometry}`.
2. **Self-capture check:** Destination must not be occupied by own piece.
   Return `{:error, :self_capture}`.
3. **Path clearance:** Iterate each intermediate square between source and
   destination along the diagonal. If any is occupied, return
   `{:error, :path_blocked}`.
4. **King safety check:** Simulate the move, verify own king not in check.
   Return `{:error, :king_in_check}`.
5. **Determine flag:**
   - Destination occupied by opponent → `:captures`
   - Otherwise → `:quiet`
6. **Return** `{:ok, %Move{from: source, to: destination, flag: flag}}`

## Test cases

### Test 1: Bishop quiet move — long diagonal

```elixir
# Board state: White bishop on c1, path clear.
# Move: c1 -> f4 (3 squares NE along diagonal)
# Expected: {:ok, %Move{from: {"c", 1}, to: {"f", 4}, flag: :quiet}}
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
# 4 |   |   |   |   |   | * |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   | . |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   | . |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 1 |   |   | B |   |   |   |   |   |  <- white bishop
#   +---+---+---+---+---+---+---+---+
```

### Test 2: Bishop quiet move — one square

```elixir
# Board state: White bishop on d4.
# Move: d4 -> c3 (1 square SW)
# Expected: {:ok, %Move{from: {"d", 4}, to: {"c", 3}, flag: :quiet}}
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
# 4 |   |   |   | B |   |   |   |   |  <- white bishop
#   +---+---+---+---+---+---+---+---+
# 3 |   |   | * |   |   |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 3: Bishop capture

```elixir
# Board state: White bishop on c1, black knight on f4, path clear.
# Move: c1 -> f4 (captures knight)
# Expected: {:ok, %Move{from: {"c", 1}, to: {"f", 4}, flag: :captures}}
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
# 4 |   |   |   |   |   | n |   |   |  <- black knight (capture target)
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   | . |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   | . |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 1 |   |   | B |   |   |   |   |   |  <- white bishop
#   +---+---+---+---+---+---+---+---+
```

### Test 4: Path blocked

```elixir
# Board state: White bishop on c1, white pawn on d2, target f4.
# Move: c1 -> f4
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
# 4 |   |   |   |   |   | X |   |   |  <- can't reach
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   | P |   |   |   |   |  <- own pawn blocks diagonal
#   +---+---+---+---+---+---+---+---+
# 1 |   |   | B |   |   |   |   |   |  <- white bishop
#   +---+---+---+---+---+---+---+---+
```

### Test 5: Invalid geometry — horizontal move

```elixir
# Board state: White bishop on c1.
# Move: c1 -> f1 (horizontal — not a bishop move)
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
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   | B |   |   | X |   |   |  <- invalid (horizontal)
#   +---+---+---+---+---+---+---+---+
```

### Test 6: Invalid geometry — L-shape

```elixir
# Board state: White bishop on c1.
# Move: c1 -> d3 (2 up, 1 right — knight move, not diagonal)
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
# 3 |   |   |   | X |   |   |   |   |  <- invalid (not diagonal)
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   | B |   |   |   |   |   |  <- white bishop
#   +---+---+---+---+---+---+---+---+
```

### Test 7: Self-capture rejected

```elixir
# Board state: White bishop on c1, white pawn on e3.
# Move: c1 -> e3
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
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   | P |   |   |   |  <- own pawn, can't capture
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   | . |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 1 |   |   | B |   |   |   |   |   |  <- white bishop
#   +---+---+---+---+---+---+---+---+
```

### Test 8: Bishop pinned to king

```elixir
# Board state: White king on a1, white bishop on b2, black bishop on d4.
#              White bishop on b2 is pinned along the a1-h8 diagonal.
# Move: b2 -> a3 (leaves diagonal, exposes king)
# Expected: {:error, :king_in_check}
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
# 4 |   |   |   | b |   |   |   |   |  <- black bishop attacks along diagonal
#   +---+---+---+---+---+---+---+---+
# 3 | X |   |   |   |   |   |   |   |  <- invalid destination (exposes king)
#   +---+---+---+---+---+---+---+---+
# 2 |   | B |   |   |   |   |   |   |  <- white bishop (pinned)
#   +---+---+---+---+---+---+---+---+
# 1 | K |   |   |   |   |   |   |   |  <- white king
#   +---+---+---+---+---+---+---+---+
```

## Implementation notes

- Direction delta: `{sign(file_delta), sign(rank_delta)}`. For a valid bishop
  move, both components will be non-zero and `abs()` values will be equal.
- The direction will match one of `Slider.bishop/0` deltas:
  `[{1,1}, {1,-1}, {-1,-1}, {-1,1}]`.
- Reuse the same path iteration pattern established by the Rook module —
  consider extracting a shared `slide_clear?/3` helper that both can call.
