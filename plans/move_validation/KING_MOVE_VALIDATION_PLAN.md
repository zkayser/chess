# King Move Validation Plan

**Module:** `Chess.BitBoards.Pieces.King`
**Behaviour:** `Chess.Moves.Validator`
**File:** `lib/chess/board/bitboards/pieces/king.ex`
**Test:** `test/chess/board/bitboards/pieces/king_test.exs`

## Overview

The King can move exactly one square in any of 8 directions. It also has
two special moves: kingside castle and queenside castle. Crucially, the King
can never move into check — every candidate destination must be verified safe.

Because every other piece module will need to call a "is the king in check after
this move?" helper, the King module should also expose a shared `in_check?/2`
utility that other modules can reuse.

## Validation steps

1. **Geometry check:** Verify `abs(file_delta) <= 1` and `abs(rank_delta) <= 1`,
   and not `{0, 0}`. If not satisfied, check for castling geometry (see below),
   otherwise return `{:error, :invalid_geometry}`.
2. **Self-capture check:** Destination must not be occupied by own piece.
   Return `{:error, :self_capture}`.
3. **King safety check:** Simulate the move on the bitboard. The destination
   square must not be attacked by any opponent piece. Return
   `{:error, :king_in_check}`.
4. **Castling** (if file delta is 2):
   - King must not have moved (no prior move in `game.move_list` with `from` at
     the king's starting square).
   - Corresponding rook must not have moved.
   - All squares between king and rook must be empty.
   - King must not currently be in check.
   - King must not pass through or land on an attacked square.
   - Return `{:error, :cannot_castle}` if any condition fails.
5. **Determine flag:**
   - Capture → `:captures`
   - Kingside castle → `:king_castle`
   - Queenside castle → `:queen_castle`
   - Otherwise → `:quiet`
6. **Return** `{:ok, %Move{from: source, to: destination, flag: flag}}`

## Shared utility to build here

```elixir
@doc """
Returns true if the king of the given color is under attack
in the given board position.
"""
@spec in_check?(BitBoard.t(), Color.t()) :: boolean()
```

This function computes whether any opponent piece attacks the king's square.
It can be done by:
- Finding the king square from the king bitboard
- For each opponent piece type, generating their attack bitboard and checking
  if it intersects the king square

## Test cases

### Test 1: King quiet move — one square forward

```elixir
# Board state: White king on e1, no other pieces nearby.
# Move: e1 -> e2 (one square forward)
# Expected: {:ok, %Move{from: {"e", 1}, to: {"e", 2}, flag: :quiet}}
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
# 2 |   |   |   |   | * |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   | K |   |   |   |  <- white king
#   +---+---+---+---+---+---+---+---+
```

### Test 2: King quiet move — diagonal

```elixir
# Board state: White king on d4, no obstructions.
# Move: d4 -> e5 (diagonal NE)
# Expected: {:ok, %Move{from: {"d", 4}, to: {"e", 5}, flag: :quiet}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   | * |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   | K |   |   |   |   |  <- white king
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 3: King capture

```elixir
# Board state: White king on e1, black pawn on f2.
# Move: e1 -> f2 (capture pawn)
# Expected: {:ok, %Move{from: {"e", 1}, to: {"f", 2}, flag: :captures}}
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
# 2 |   |   |   |   |   | p |   |   |  <- black pawn (capture target)
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   | K |   |   |   |  <- white king
#   +---+---+---+---+---+---+---+---+
```

### Test 4: King self-capture rejected

```elixir
# Board state: White king on e1, white pawn on e2.
# Move: e1 -> e2
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
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   | P |   |   |   |  <- own pawn blocks
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   | K |   |   |   |  <- white king
#   +---+---+---+---+---+---+---+---+
```

### Test 5: Invalid geometry — move too far

```elixir
# Board state: White king on e1.
# Move: e1 -> e3 (two squares — not valid king move, not castling)
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
# 3 |   |   |   |   | X |   |   |   |  <- invalid destination
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   | K |   |   |   |  <- white king
#   +---+---+---+---+---+---+---+---+
```

### Test 6: King cannot move into check

```elixir
# Board state: White king on e1, black rook on f8.
# Move: e1 -> f1 (f-file is attacked by rook)
# Expected: {:error, :king_in_check}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   | r |   |   |  <- black rook controls f-file
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
# 1 |   |   |   |   | K | X |   |   |  <- f1 attacked, can't go there
#   +---+---+---+---+---+---+---+---+
```

### Test 7: Kingside castling — success

```elixir
# Board state: White king on e1 (unmoved), white rook on h1 (unmoved),
#              squares f1 and g1 empty, not attacked.
# Move: e1 -> g1
# Expected: {:ok, %Move{from: {"e", 1}, to: {"g", 1}, flag: :king_castle}}
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
# 1 |   |   |   |   | K |   | * | R |  <- king castles to g1
#   +---+---+---+---+---+---+---+---+
```

### Test 8: Queenside castling — success

```elixir
# Board state: White king on e1 (unmoved), white rook on a1 (unmoved),
#              squares b1, c1, d1 empty, king doesn't pass through check.
# Move: e1 -> c1
# Expected: {:ok, %Move{from: {"e", 1}, to: {"c", 1}, flag: :queen_castle}}
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
# 1 | R |   | * |   | K |   |   |   |  <- king castles to c1
#   +---+---+---+---+---+---+---+---+
```

### Test 9: Castling rejected — king has moved

```elixir
# Board state: Same as Test 7, but move_list contains a prior king move
#              (king moved away and back to e1).
# Move: e1 -> g1
# Expected: {:error, :cannot_castle}
```

### Test 10: Castling rejected — square under attack

```elixir
# Board state: White king on e1, white rook on h1, black bishop on b4
#              (which attacks f1 diagonally, so king would pass through check).
# Move: e1 -> g1
# Expected: {:error, :cannot_castle}
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
# 4 |   | b |   |   |   |   |   |   |  <- black bishop attacks f1
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   | K |   | X | R |  <- f1 attacked, can't castle
#   +---+---+---+---+---+---+---+---+
```

### Test 11: King corner movement — boundary check

```elixir
# Board state: White king on a1.
# Move: a1 -> b2 (only 3 valid moves from a1: a2, b1, b2)
# Expected: {:ok, %Move{from: {"a", 1}, to: {"b", 2}, flag: :quiet}}
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
# 2 |   | * |   |   |   |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 1 | K |   |   |   |   |   |   |   |  <- white king in corner
#   +---+---+---+---+---+---+---+---+
```

## Implementation notes

- Use `Square.try_delta/2` to verify the destination is within bounds and
  exactly one king-step away. The 8 king deltas are:
  `[{-1,-1},{-1,0},{-1,1},{0,-1},{0,1},{1,-1},{1,0},{1,1}]`
- For castling, derive king/rook starting squares from color:
  - White: king `{"e", 1}`, kingside rook `{"h", 1}`, queenside rook `{"a", 1}`
  - Black: king `{"e", 8}`, kingside rook `{"h", 8}`, queenside rook `{"a", 8}`
- The `in_check?/2` helper should be built and tested as part of this module,
  then used by all subsequent piece modules.
- For scanning move history to check "has king/rook moved", scan
  `game.move_list` for any move with `from` matching the relevant starting square.
