# Pawn Move Validation Plan

**Module:** `Chess.BitBoards.Pieces.Pawn`
**Behaviour:** `Chess.Moves.Validator`
**File:** `lib/chess/board/bitboards/pieces/pawn.ex`
**Test:** `test/chess/board/bitboards/pieces/pawn_test.exs`

## Overview

The Pawn is the most complex piece to validate due to its directional movement,
special first-move double push, diagonal-only captures, en passant, and
promotion. This module already has `single_pushes/2`, `double_pushes/2`, and
`potential_attacks/2` for bitboard-level move generation. `validate_move/2`
validates a specific proposed move against the game state.

## Direction

- White pawns move toward rank 8 (rank increases).
- Black pawns move toward rank 1 (rank decreases).
- Starting ranks: white rank 2, black rank 7.
- Promotion ranks: white rank 8, black rank 1.

## Validation steps

1. **Direction check:** Ensure the pawn moves in the correct direction for its
   color. White must increase rank, black must decrease rank. Return
   `{:error, :invalid_geometry}` if violated.
2. **Move type classification:** Based on file and rank deltas, determine if
   this is a single push, double push, or diagonal (capture/en passant).
3. **Single push (file_delta=0, rank_delta=1):**
   - Destination must be empty. Return `{:error, :path_blocked}` if occupied.
   - If destination is the promotion rank, flag is a promotion flag
     (default `:queen_promotion`; the proposal may specify the piece).
   - Otherwise flag is `:quiet`.
4. **Double push (file_delta=0, rank_delta=2):**
   - Source must be on starting rank. Return `{:error, :invalid_double_push}`.
   - Both the intermediate square and destination must be empty. Return
     `{:error, :path_blocked}` if either is occupied.
   - Flag is `:double_pawn_push`.
5. **Diagonal move (abs(file_delta)=1, abs(rank_delta)=1):**
   - **Standard capture:** Destination occupied by opponent → flag is
     `:captures` (or promotion-capture variant if promotion rank).
   - **En passant:** Destination is empty, but the last move in
     `game.move_list` was a double pawn push by the opponent that landed
     adjacent to our pawn (same rank, adjacent file). The destination is the
     square the opponent pawn passed through. Flag is `:en_passant_captures`.
   - If neither condition met → `{:error, :no_capture_target}`.
6. **Any other geometry:** `{:error, :invalid_geometry}`.
7. **King safety check:** Simulate the move, verify own king not in check.
   Return `{:error, :king_in_check}`.
8. **Return** `{:ok, %Move{from: source, to: destination, flag: flag}}`

## En passant detail

En passant is legal only when ALL of these hold:

- The last move in `game.move_list` has flag `:double_pawn_push`.
- That move's `to` coordinate is on the same rank as our pawn's source.
- That move's `to` file is adjacent to our pawn's source file (abs(file_delta)=1).
- Our pawn's destination is the square "behind" the opponent's pawn
  (one rank forward from our pawn on the adjacent file).

## Promotion detail

When a pawn reaches the promotion rank (rank 8 for white, rank 1 for black),
the move must include a promotion flag. The `Proposals` struct may be extended
to include a promotion choice, but the default should be `:queen_promotion`.
Promotion-capture variants exist for diagonal moves to the promotion rank.

Promotion flags:
- Non-capture: `:knight_promotion`, `:bishop_promotion`, `:rook_promotion`, `:queen_promotion`
- Capture: `:knight_promotion_capture`, `:bishop_promotion_capture`,
  `:rook_promotion_capture`, `:queen_promotion_capture`

## Test cases

### Test 1: White pawn single push

```elixir
# Board state: White pawn on e2, destination e3 is empty.
# Move: e2 -> e3
# Expected: {:ok, %Move{from: {"e", 2}, to: {"e", 3}, flag: :quiet}}
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
# 3 |   |   |   |   | * |   |   |   |  <- destination (empty)
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   | P |   |   |   |  <- white pawn
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 2: White pawn double push from starting rank

```elixir
# Board state: White pawn on e2, e3 and e4 both empty.
# Move: e2 -> e4
# Expected: {:ok, %Move{from: {"e", 2}, to: {"e", 4}, flag: :double_pawn_push}}
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
# 4 |   |   |   |   | * |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   | . |   |   |   |  <- intermediate (must be empty)
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   | P |   |   |   |  <- white pawn on starting rank
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 3: Double push rejected — not on starting rank

```elixir
# Board state: White pawn on e3 (already moved).
# Move: e3 -> e5 (two squares, but not from starting rank)
# Expected: {:error, :invalid_double_push}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   | X |   |   |   |  <- invalid (not from starting rank)
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   | P |   |   |   |  <- pawn already on rank 3
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 4: Double push rejected — path blocked

```elixir
# Board state: White pawn on e2, black piece on e3.
# Move: e2 -> e4
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
# 4 |   |   |   |   | X |   |   |   |  <- can't reach
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   | p |   |   |   |  <- opponent piece blocks
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   | P |   |   |   |  <- white pawn
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 5: Pawn standard capture — diagonal

```elixir
# Board state: White pawn on e4, black pawn on d5.
# Move: e4 -> d5 (diagonal capture)
# Expected: {:ok, %Move{from: {"e", 4}, to: {"d", 5}, flag: :captures}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   | p |   |   |   |   |  <- black pawn (capture target)
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   | P |   |   |   |  <- white pawn
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 6: Diagonal move with no target — rejected

```elixir
# Board state: White pawn on e4, d5 is empty.
# Move: e4 -> d5 (diagonal but nothing to capture)
# Expected: {:error, :no_capture_target}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   | X |   |   |   |   |  <- empty, no capture possible
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   | P |   |   |   |  <- white pawn
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 7: En passant capture — white

```elixir
# Board state: White pawn on e5, black pawn on d5.
#              Last move in move_list: black pawn d7->d5 (double_pawn_push).
# Move: e5 -> d6 (en passant — captures the pawn that just double-pushed)
# Expected: {:ok, %Move{from: {"e", 5}, to: {"d", 6}, flag: :en_passant_captures}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   |   |   |   |   |  <- black pawn WAS here (d7)
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   | * |   |   |   |   |  <- en passant destination (d6)
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   | p | P |   |   |   |  <- black pawn just arrived (d5), white pawn (e5)
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 8: En passant rejected — not immediately after double push

```elixir
# Board state: White pawn on e5, black pawn on d5.
#              But the last move was NOT a double pawn push to d5
#              (some other move happened in between).
# Move: e5 -> d6
# Expected: {:error, :invalid_en_passant}
```

### Test 9: Single push blocked

```elixir
# Board state: White pawn on e4, black pawn on e5.
# Move: e4 -> e5 (blocked — pawn can't push into occupied square)
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
# 5 |   |   |   |   | p |   |   |   |  <- blocked by black pawn
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   | P |   |   |   |  <- white pawn
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 10: Backward move rejected

```elixir
# Board state: White pawn on e4.
# Move: e4 -> e3 (backward — pawns can't go backward)
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
# 4 |   |   |   |   | P |   |   |   |  <- white pawn
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   | X |   |   |   |  <- can't go backward
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 11: Promotion — single push to rank 8

```elixir
# Board state: White pawn on e7, e8 is empty.
# Move: e7 -> e8
# Expected: {:ok, %Move{from: {"e", 7}, to: {"e", 8}, flag: :queen_promotion}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   | * |   |   |   |  <- promotion rank (destination)
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   | P |   |   |   |  <- white pawn about to promote
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
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 12: Promotion capture — diagonal to rank 8

```elixir
# Board state: White pawn on e7, black rook on d8.
# Move: e7 -> d8 (diagonal capture + promotion)
# Expected: {:ok, %Move{from: {"e", 7}, to: {"d", 8}, flag: :queen_promotion_capture}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   | r |   |   |   |   |  <- capture + promote
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   |   | P |   |   |   |  <- white pawn
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
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 13: Black pawn single push (reverse direction)

```elixir
# Board state: Black pawn on d7, d6 is empty. current_player is :black.
# Move: d7 -> d6
# Expected: {:ok, %Move{from: {"d", 7}, to: {"d", 6}, flag: :quiet}}
#
#     a   b   c   d   e   f   g   h
#   +---+---+---+---+---+---+---+---+
# 8 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 7 |   |   |   | p |   |   |   |   |  <- black pawn
#   +---+---+---+---+---+---+---+---+
# 6 |   |   |   | * |   |   |   |   |  <- destination
#   +---+---+---+---+---+---+---+---+
# 5 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 4 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

### Test 14: Horizontal pawn move rejected

```elixir
# Board state: White pawn on e4.
# Move: e4 -> f4 (sideways — pawns can't do this)
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
# 4 |   |   |   |   | P | X |   |   |  <- can't move sideways
#   +---+---+---+---+---+---+---+---+
# 3 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 2 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
# 1 |   |   |   |   |   |   |   |   |
#   +---+---+---+---+---+---+---+---+
```

## Implementation notes

- Direction multiplier: `forward = if color == :white, do: 1, else: -1`.
  A valid rank delta is `forward * 1` for single push, `forward * 2` for double.
- Starting rank: white = 2, black = 7.
- Promotion rank: white = 8, black = 1.
- The existing `single_pushes/2`, `double_pushes/2`, and `potential_attacks/2`
  generate bitboards for all pawns at once — they are useful for `in_check?`
  calculations but `validate_move/2` works on a single proposed move.
- For en passant, inspect `List.first(game.move_list)` — it must be a
  `%Move{flag: :double_pawn_push}` whose `to` coordinate is adjacent.
- Promotion flag selection may require extending `Proposals.t()` to include an
  optional `:promotion_piece` field, or default to `:queen_promotion`.
