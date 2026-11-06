## 0.0.7

* `pieceBuilder` draws the piece on a square in place of the `pieceMap` art; `null` keeps the `pieceMap` art, and a board without it is unchanged. It is told where the piece came from in this state change (`from`, and `fromOffset` in the piece's own upright frame, orientation and turned top player pieces included). A `SquarePiece` with `ownsTravel: true` animates its own move: the board places it on its square at once and draws it over the other pieces.

## 0.0.6

* Arrows take an optional `width` (logical pixels, default 4). The arrowhead grows with it.
* An arrow is drawn as one path, so a translucent arrow has an even tint instead of a darker tip.
* Requires Flutter 3.27 or newer.

## 0.0.5

* Add opt-in keyboard shortcut selection (`shortcuts: ShortcutArgs(...)`): type `a`–`h` then `1`–`8` then space to commit, or use `ShortcutCommitMode.auto` to commit on digit. Restyleable via `highlightBuilder`; default `ShortcutHighlight` widget exported.

## 0.0.4

* Prevent an exception when "reusing" the controller (fixed by @topse)

## 0.0.3

* Fix static analysis

* Update Example to allow casteling

## 0.0.2

* Export all important models directly

## 0.0.1

* Initial Release
