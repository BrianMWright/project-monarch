## main.gd
extends Control

var _label_tile: Label
var _label_roll: Label


func _ready() -> void:
	print("[Main] _ready() start")

	await get_tree().process_frame

	print("[Main] after frame")

	var dice_roller: DiceRoller = $DiceRoller
	var player: Player = $Player
	var button_roll: Button = $ButtonRoll
	_label_tile = $LabelTile
	_label_roll = $LabelRoll

	print("[Main] nodes found, wiring signals")

	dice_roller.rolled.connect(player.move_player)
	dice_roller.rolled.connect(_on_rolled)
	player.tile_landed.connect(_on_tile_landed)
	button_roll.pressed.connect(dice_roller.roll)

	_label_roll.text = "READY"
	_label_tile.text = "MAIN LOADED"

	print("[Main] _ready() complete")


func _on_rolled(steps: int) -> void:
	_label_roll.text = "Roll: %d" % steps


func _on_tile_landed(tile: Dictionary) -> void:
	_label_tile.text = "Tile: %s" % tile.get("name", "-")
