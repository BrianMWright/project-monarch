## Player.gd
## Represents a single player token on the board.

class_name Player
extends Node

signal tile_landed(tile: Dictionary)
signal balance_changed(balance: int)
signal turn_resolved(summary: String)

var current_tile_index: int = 0

@export var player_name: String = "Player"
@export var starting_balance: int = 1500
@export var board_data: BoardData
var balance: int = starting_balance


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
	_resolve_tile(tile)


func reset_state() -> void:
	current_tile_index = 0
	balance = starting_balance
	balance_changed.emit(balance)


func _resolve_tile(tile: Dictionary) -> void:
	var amount: int = int(tile.get("amount", 0))
	balance += amount
	balance_changed.emit(balance)

	var summary: String
	if amount > 0:
		summary = "%s gained $%d on %s." % [player_name, amount, tile.get("name", "this tile")]
	elif amount < 0:
		summary = "%s paid $%d on %s." % [player_name, abs(amount), tile.get("name", "this tile")]
	else:
		summary = "%s visited %s." % [player_name, tile.get("name", "this tile")]

	turn_resolved.emit(summary)
