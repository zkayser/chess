# AGENTS.md

## Project overview

Elixir chess engine + Phoenix web UI. The engine uses **bitboard** representations
(64-bit binaries encoding piece positions) inspired by
<https://www.chessprogramming.org/Bitboards>. See `MOVE_VALIDATION_PLAN.md` for
the planned implementation roadmap.

The bitboard implementation is incomplete — only Pawn has move generation logic;
Knight, Bishop, Rook, Queen, and King are stubs. This is expected.

## Toolchain

- Elixir 1.18.4 / OTP 28 (pinned in `.tool-versions`)
- Phoenix ~> 1.8 with LiveView ~> 1.1
- PostgreSQL (Postgrex + Ecto)
- `stream_data` for property-based testing (available in all envs)
- `oath` for design-by-contract (dev + test)

## Commands

```bash
mix setup              # deps.get + ecto.create + ecto.migrate + seeds
mix test               # creates/migrates DB quietly, then runs tests
mix test path/to/test.exs          # single file
mix test path/to/test.exs:42       # single test at line
mix credo --strict                 # lint (CI uses --strict)
mix format --check-formatted       # formatter check
mix format                         # auto-format
mix dialyzer                       # static analysis (CI job disabled but tool works locally)
```

CI runs lint before test (`mix credo --strict && mix format --check-formatted`,
then `mix test`). CI uses devcontainers with a Postgres service.

## Architecture

### Board representation

The engine uses a single bitboard-based representation:

- `Chess.Boards.BitBoard` — `<<_::64>>` per piece-type per color
- `Chess.BitBoards.Pieces.{Pawn,Knight,Bishop,Rook,Queen,King}` — piece modules (only Pawn implemented, rest are stubs)
- `Chess.Game` — game state struct using `BitBoard.t()`
- `Chess.Pieces` — classifier that maps board coordinates to piece modules

### Module naming (inconsistent — be aware)

Namespaces mix `Board`/`Boards`, `Bitboard`/`BitBoard`/`BitBoards`/`Bitboards`.
Follow the existing pattern for the specific area you're editing rather than
trying to normalize.

### Key types

- `Chess.player()` — `:white | :black`
- `Chess.Board.Coordinates.t()` — `{file_string, rank_int}` where file is `"a"`-`"h"`, rank is `1..8`
- `Chess.Boards.BitBoard.bitboard()` — `<<_::64>>` (64-bit binary)
- `Chess.Bitboards.Move.t()` — 16-bit encoded move with from/to coordinates + 4-bit flag
- `Chess.Bitboards.Move.coordinate()` — `{String.t(), 1..8}` (file string, rank int)

### Bitboard conventions

- Bitboards are 64-bit binaries, not integers. Use `Chess.Boards.BitBoard.from_integer/1` to convert.
- `import Bitwise` (not `use Bitwise`) in bitboard modules.
- File masks (`@file_a_mask`, `@file_h_mask`) prevent wraparound in shift-based attack generation.
- Coordinate conversion utilities live in `lib/chess/board/bitboards/move.ex`.
- Slider deltas (rook/bishop directions) are in `lib/chess/board/bitboards/slider.ex`.

### Move system

- `Chess.Moves.Validator` behaviour defines `validate_move/2` — **not yet implemented** by any piece module.
- `MOVE_VALIDATION_PLAN.md` specifies implementation order: King -> Knight -> Rook -> Bishop -> Queen -> Pawn.
- `Chess.Moves.Proposals` parses raw user input (e.g., `"a2"`, `"a4"`) into structured proposals.

### Web layer

Minimal: single `PageController`, traditional Phoenix views + EEx templates.
LiveDashboard at `/dashboard` (dev/test only).

## Testing conventions

- Property-based tests (`use ExUnitProperties` + `StreamData`) are used extensively.
- Compile-time test generation via `for` comprehensions with `unquote` creates parameterized test cases.
- Test support modules compiled from `test/support/` (via `elixirc_paths(:test)`).
- Tests require Postgres running — the `mix test` alias handles DB setup automatically.
- Test file paths mirror source: `lib/chess/board/bitboard.ex` -> `test/chess/board/bitboard_test.exs`.

## Coding conventions

- `@spec` on all public functions. `@moduledoc` on every module.
- `@behaviour` + `@impl` annotations used consistently.
- No custom `.credo.exs` — uses default Credo rules with `--strict` flag.
- Dialyzer PLTs stored at `priv/plts`.

## Database

- Ecto with Postgres. Dev: `postgres:postgres@localhost/chess_dev`. Test: `chess_test`.
- **No migrations exist yet.** Seeds file is a placeholder.
- Devcontainer provides Postgres 17.6 via docker-compose.

## Devcontainer

- `.devcontainer/` has docker-compose with `elixir:1.18.4-otp-28` + `postgres:17.6`
- `./run` script: `sudo docker compose -f .devcontainer/docker-compose.yml exec app "$@"`
- `DATABASE_URL=ecto://postgres:postgres@db:5432/chess_dev` inside container
