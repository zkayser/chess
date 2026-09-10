# Move Validation Implementation Plan

## Objective

Implement `validate_move/2` on each bitboard piece module (`Chess.BitBoards.Pieces.*`)
using the `Chess.Moves.Validator` behaviour. All validation logic operates on
`Chess.Boards.BitBoard.t()` bitboards (64-bit binaries) and returns
`Chess.Bitboards.Move.t()` structs with appropriate flags.

## Interface

Every piece module implements:

```elixir
@behaviour Chess.Moves.Validator

@impl Chess.Moves.Validator
@spec validate_move(Chess.Game.t(), Chess.Moves.Proposals.t()) ::
        {:ok, Chess.Bitboards.Move.t()} | {:error, atom()}
def validate_move(game, proposal)
```

### Parameters

- `game` — `Chess.Game.t()` containing:
  - `board` — `Chess.Boards.BitBoard.t()` (per-color, per-piece-type bitboards)
  - `move_list` — `list(Chess.Bitboards.Move.t())` (needed for en passant, castling rights)
  - `current_player` — `:white | :black`
- `proposal` — `Chess.Moves.Proposals.t()` with `source` and `destination` as
  `{file_string, rank_int}` coordinates

### Return values

- `{:ok, %Chess.Bitboards.Move{from: coord, to: coord, flag: flag}}` on success
- `{:error, reason_atom}` on failure

### Hot-path square types (Option A)

`Proposals` and `%Move{}` keep `{file, rank}` tuples for legibility (tests,
docs, I/O). Validators convert **once** at entry and compute with masks:

```elixir
{from_mask, to_mask} = Proposals.masks(proposal)

# occupancy / attacks / simulation use from_mask and to_mask
# ...

# Build the returned move with the original tuples; pass to_mask so
# quiet/capture inference does not convert destination again:
{:ok, Move.make(game, proposal.source, proposal.destination, to_mask)}
# or an explicit flag: Move.make(game, from, to, :king_castle)
```

Prefer `BitBoard.occupied?/2`, `Square.mask/1` / `mask_from_index/1`, and
`Proposals.masks/1` over `BitBoard.square_occupied?/2` and repeated
`Coordinates.file_bit_index/1` calls inside validation.

### Standard error atoms

| Atom | Meaning |
|---|---|
| `:unoccupied` | No piece of the current player at source |
| `:wrong_piece` | Source has a piece but not the one this module handles |
| `:self_capture` | Destination occupied by own piece |
| `:invalid_geometry` | Move shape doesn't match piece rules |
| `:path_blocked` | Sliding piece path obstructed |
| `:king_in_check` | Move would leave own king in check |
| `:invalid_double_push` | Pawn double push not from starting rank or path blocked |
| `:no_capture_target` | Pawn diagonal move with no opponent piece |
| `:invalid_en_passant` | En passant conditions not met |
| `:cannot_castle` | Castling conditions not met |

## Key utilities

All validation should use these existing modules — no local coordinate math:

| Module | Key functions | Purpose |
|---|---|---|
| `Chess.Boards.BitBoard` | `get/2`, `get_raw/2`, `get_boards_by_color/2`, `occupied?/2`, `from_integer/1`, `empty/0` | Read and compose bitboards; mask-based occupancy |
| `Chess.Boards.Bitboards.Square` | `try_delta/2`, `mask/1`, `mask_from_index/1`, `to_index/1` | Coordinate arithmetic, single-square masks / indices |
| `Chess.Moves.Proposals` | `masks/1` | Tuple → mask conversion once at validator entry |
| `Chess.Bitboards.Move` | `make/3`, `make/4`, `encode/1`, `decode/1`, `flags/0` | Build `%Move{}` (tuples stored; mask or flag for inference) |
| `Chess.Bitboards.Slider` | `rook/0`, `bishop/0` | Delta lists for sliding directions |
| `Chess.Board.Coordinates` | `file_bit_index/1` | File-to-bit-index mapping (prefer via `Square`) |
| `Chess.Pieces` | `classify/2` | Identify which piece occupies a square (mask or tuple) |

## Shared helper: occupancy checks

Most pieces need these operations — factor them out or inline per module:

```elixir
{from_mask, to_mask} = Proposals.masks(proposal)

# Composite bitboard of all own pieces
own_pieces = BitBoard.get_raw(game.board, game.current_player)

# Composite bitboard of all opponent pieces
opponent = if game.current_player == :white, do: :black, else: :white
opponent_pieces = BitBoard.get_raw(game.board, opponent)

# All occupied squares
all_occupied = own_pieces ||| opponent_pieces

# Check self-capture / capture via mask AND (no tuple parsing)
self_capture? = BitBoard.occupied?(own_pieces, to_mask)
capture? = BitBoard.occupied?(opponent_pieces, to_mask)
```

## Shared helper: king safety

After any candidate move, verify the own king is not in check.
This requires temporarily applying the move to the bitboard and then
checking whether any opponent piece attacks the king square. This will
be needed by every piece module but is most naturally built alongside
the King module first.

## Implementation order

```
King -> Knight -> Rook -> Bishop -> Queen -> Pawn
```

**Rationale:** King is simplest geometry (1-square, 8 directions) and forces
building the king-safety check infrastructure that all other pieces need.
Knight is the other non-sliding piece. Rook and Bishop establish sliding
logic. Queen composes Rook + Bishop. Pawn is last because it has the most
special cases (double push, en passant, promotion).

## Detailed plans

Each piece has a dedicated implementation plan with concrete test cases:

- [`plans/move_validation/KING_MOVE_VALIDATION_PLAN.md`](plans/move_validation/KING_MOVE_VALIDATION_PLAN.md)
- [`plans/move_validation/KNIGHT_MOVE_VALIDATION_PLAN.md`](plans/move_validation/KNIGHT_MOVE_VALIDATION_PLAN.md)
- [`plans/move_validation/ROOK_MOVE_VALIDATION_PLAN.md`](plans/move_validation/ROOK_MOVE_VALIDATION_PLAN.md)
- [`plans/move_validation/BISHOP_MOVE_VALIDATION_PLAN.md`](plans/move_validation/BISHOP_MOVE_VALIDATION_PLAN.md)
- [`plans/move_validation/QUEEN_MOVE_VALIDATION_PLAN.md`](plans/move_validation/QUEEN_MOVE_VALIDATION_PLAN.md)
- [`plans/move_validation/PAWN_MOVE_VALIDATION_PLAN.md`](plans/move_validation/PAWN_MOVE_VALIDATION_PLAN.md)
