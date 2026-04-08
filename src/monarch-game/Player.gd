## Player.gd
## Represents a single player token on the board.
##
## Live Ops note: Emit signals on key state changes (tile landed, balance
## updated, etc.) so a future analytics or event system can subscribe without
## modifying this class.

class_name Player
extends Node

signal tile_landed(tile: Dictionary)

var current_tile_index: int = 0

@export var player_name: String = "Player"
@export var board_data: BoardData


func move_player(steps: int) -> void:
	assert(steps >= 0, "steps must be a non-negative integer.")
	assert(board_data != null, "board_data must be assigned before calling move_player().")

	current_tile_index = (current_tile_index + steps) % board_data.get_tile_count()

	var tile: Dictionary = board_data.get_tile(current_tile_index)

	print("[%s] Moved %d step(s) -> landed on: %s (type: %s)" % [
		player_name,
		steps,
		tile.get("name", "Unknown"),
		tile.get("type", "unknown"),
	])

	tile_landed.emit(tile)
