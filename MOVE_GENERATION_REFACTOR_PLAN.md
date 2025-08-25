# Move Generation Refactor Plan

This document outlines the steps to refactor the move generation logic to use bitwise operations directly, instead of returning a list of board indices. This will make the move generation more idiomatic for a bitboard-based chess engine and potentially more performant.

## 1. Change `potential_moves` function signature

The `potential_moves` function in the `Piece` behaviour currently returns a `MapSet.t(Board.index())`. This should be changed to return a `BitBoard.bitboard()`, which is a 64-bit integer representing all possible move destinations.

-   Update `lib/chess/pieces/piece.ex` to change the `@callback` for `potential_moves/3`.
-   Update all modules that implement the `Piece` behaviour (`Pawn`, `Rook`, etc.) to match the new signature.

## 2. Refactor `Pawn.potential_moves`

-   The function will now calculate moves using bitwise shifts on a bitmask of the pawn's position.
-   Single-step forward move for a white pawn at index `i`: `(1 <<< i) <<< 8`.
-   Two-step forward move: `(1 <<< i) <<< 16`.
-   Captures: `(1 <<< i) <<< 7` and `(1 <<< i) <<< 9`.
-   The function will need to handle edge cases (e.g., wrapping around the board for captures) by masking with a "not-a-file" or "not-h-file" mask.
-   The final result will be a bitboard created by `|||`-ing the bitboards of all possible moves.

## 3. Refactor other piece move generation

-   Update `Rook`, `Bishop`, `Queen`, `Knight`, and `King` move generation to return a bitboard.
-   This will involve more complex logic for sliding pieces, likely using pre-calculated attack tables or techniques like "magic bitboards".

## 4. Update move validation and application

-   `Moves.Proposals.validate/2` will need to be updated. Instead of checking if a proposed move index is in a `MapSet`, it will check if the bit for the destination square is set in the potential moves bitboard.
    -   `potential_moves_bitboard &&& (1 <<< to_index) != 0`
-   This will require changes in `lib/chess/moves/proposals.ex`.

## 5. Update tests

-   All tests for `potential_moves` functions will need to be updated to work with bitboards instead of `MapSet`s of indices.
-   This will involve creating expected bitboards for assertions.
