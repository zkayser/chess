# Rook Move Validation Plan

**Module:** `Chess.BitBoards.Pieces.Rook`
**Behaviour:** `Chess.Moves.Validator`
**File:** `lib/chess/board/bitboards/pieces/rook.ex`
**Test:** `test/chess/board/bitboards/pieces/rook_test.exs`

## Overview

The Rook slides any number of squares along a rank (horizontal) or file
(vertical). It cannot jump over pieces. This is the first sliding piece to
implement, so it establishes the path-clearance pattern reused by Bishop and
Queen.

## Validation steps

1. **Geometry check:** The move must be purely horizontal (same rank, different
   file) or purely vertical (same file, different rank). If both file and rank
   change, return `{:error, :invalid_geometry}`.
2. **Self-capture check:** Destination must not be occupied by own piece.
   Return `{:error, :self_capture}`.
3. **Path clearance:** Iterate through each intermediate square between source
   and destination. If any square is occupied (by any piece), return
   `{:error, :path_blocked}`. Use `Square.try_delta/2` to step through the
   path one square at a time using the appropriate direction delta from
   `Slider.rook/0`.
4. **King safety check:** Simulate the move and verify own king is not in
   check. Return `{:error, :king_in_check}`.
5. **Determine flag:**
   - Destination occupied by opponent → `:captures`
   - Otherwise → `:quiet`
6. **Return** `{:ok, %Move{from: source, to: destination, flag: flag}}`

## Path clearance algorithm

```
direction = {sign(file_delta), sign(rank_delta)}
# For a rook, one of these will always be 0
current = source
loop:
  current = try_delta(current, direction)
  if current == destination -> break (clear path)
  if square occupied at current -> :path_blocked
```

Use `BitBoard.get_raw(game.board, :full)` or compose own + opponent bitboards
to get the full occupancy, then check each intermediate square via
`BitBoard.square_occupied?/2` using the composite bitboard.

## Test cases

### Test 1: Rook quiet move — vertical

```elixir
# Board state: White rook on a1, path clear.
# Move: a1 -> a5 (4 squares up along a-file)
# Expected: {:ok, %Move{from: {"a", 1}, to: {"a", 5}, flag: :quiet}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 | * |   |   |   |   |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 4 | . |   |   |   |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 3 | . |   |   |   |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 2 | . |   |   |   |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 1 | R |   |   |   |   |   |   |   |  <- white rook
#   +---+---+---+---+---+---+---+---+
```

### Test 2: Rook quiet move — horizontal

```elixir
# Board state: White rook on a4, path clear.
# Move: a4 -> h4 (7 squares right along rank 4)
# Expected: {:ok, %Move{from: {"a", 4}, to: {"h", 4}, flag: :quiet}}
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
# 4 | R | . | . | . | . | . | . | * |  <- rook slides to h4
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 3: Rook capture

```elixir
# Board state: White rook on a1, black pawn on a5, path clear between.
# Move: a1 -> a5 (captures pawn)
# Expected: {:ok, %Move{from: {"a", 1}, to: {"a", 5}, flag: :captures}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 | p |   |   |   |   |   |   |   |  <- black pawn (capture target)
#   +---+---+---+---+---+---+---+---+
# 4 | . |   |   |   |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 3 | . |   |   |   |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 2 | . |   |   |   |   |   |   |   |  <- clear
#   +---+---+---+---+---+---+---+---+
# 1 | R |   |   |   |   |   |   |   |  <- white rook
#   +---+---+---+---+---+---+---+---+
```

### Test 4: Path blocked

```elixir
# Board state: White rook on a1, white pawn on a3. Destination a5.
# Move: a1 -> a5
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
# 5 | X |   |   |   |   |   |   |   |  <- can't reach
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 | P |   |   |   |   |   |   |   |  <- own pawn blocks path
#   +---+---+---+---+---+---+---+---+
# 2 | . |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 | R |   |   |   |   |   |   |   |  <- white rook
#   +---+---+---+---+---+---+---+---+
```

### Test 5: Invalid geometry — diagonal

```elixir
# Board state: White rook on a1.
# Move: a1 -> c3 (diagonal — not a rook move)
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
# 3 |   |   | X |   |   |   |   |   |  <- invalid (diagonal)
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 | R |   |   |   |   |   |   |   |  <- white rook
#   +---+---+---+---+---+---+---+---+
```

### Test 6: Self-capture rejected

```elixir
# Board state: White rook on a1, white knight on a3.
# Move: a1 -> a3
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
# 3 | N |   |   |   |   |   |   |   |  <- own knight, can't capture
#   +---+---+---+---+---+---+---+---+
# 2 | . |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 | R |   |   |   |   |   |   |   |  <- white rook
#   +---+---+---+---+---+---+---+---+
```

### Test 7: Rook move one square

```elixir
# Board state: White rook on d4.
# Move: d4 -> d5 (one square up)
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
# 4 |   |   |   | R |   |   |   |   |  <- white rook
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 8: Blocked by opponent (not at destination)

```elixir
# Board state: White rook on a1, black pawn on a3, target a5.
#              Even though a3 is an opponent piece, it blocks the PATH
#              (the rook would have to jump over it to reach a5).
# Move: a1 -> a5
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
# 5 | X |   |   |   |   |   |   |   |  <- can't reach
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 | p |   |   |   |   |   |   |   |  <- opponent pawn blocks path
#   +---+---+---+---+---+---+---+---+
# 2 | . |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 | R |   |   |   |   |   |   |   |  <- white rook
#   +---+---+---+---+---+---+---+---+
```

## Implementation notes

- Direction delta is derived from the move: `{sign(file_delta), sign(rank_delta)}`.
  For a valid rook move, exactly one component will be 0.
- The direction delta will always match one of `Slider.rook/0` deltas:
  `[{1,0}, {0,-1}, {-1,0}, {0,1}]`.
- Use `Square.try_delta/2` to iterate one step at a time from source toward
  destination, checking occupancy at each intermediate square.
- Build a combined occupancy bitboard once and use `BitBoard.square_occupied?/2`
  against it for each intermediate square.
