## Player.gd
## Represents a single player token on the board.
##
## Live Ops note: Emit signals on key state changes (tile landed, balance
## updated, etc.) so a future analytics or event system can subscribe without
## modifying this class.

class_name Player
extends Node

# ---------------------------------------------------------------------------
# Signals — wire these up for UI, analytics, and Live Ops event hooks.
# ---------------------------------------------------------------------------

## Emitted after the player lands on a new tile.
## [param tile] is the full tile Dictionary from BoardData.
signal tile_landed(tile: Dictionary)

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

## Zero-based index of the tile the player currently occupies.
## Wraps around the board using BoardData.tiles.size().
var current_tile_index: int = 0

## Display name for this player (e.g. "Player 1", or a remote profile name).
## Live Ops note: Populate from a player-profile service at session start.
@export var player_name: String = "Player"

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------

## Reference to the shared board data.
## Assign in the editor or via code before calling move_player().
@export var board_data: BoardData


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Moves the player forward by [param steps] tiles and prints the name of
## the tile landed on.
##
## [param steps] — number of tiles to advance (must be >= 0).
##
## Live Ops note: Add a pre-move hook here to apply event modifiers
## (e.g. "double movement" buffs delivered via remote config).
func move_player(steps: int) -> void:
	assert(steps >= 0, "steps must be a non-negative integer.")
	assert(board_data != null, "board_data must be assigned before calling move_player().")

	current_tile_index = (current_tile_index + steps) % 4

	var tile: Dictionary = board_data.get_tile(current_tile_index)

	print("[%s] Moved %d step(s) → landed on: %s (type: %s)" % [
		player_name,
		steps,
		tile.get("name", "Unknown"),
		tile.get("type", "unknown"),
	])

	tile_landed.emit(tile)
