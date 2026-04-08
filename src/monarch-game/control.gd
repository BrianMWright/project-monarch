## control.gd
## Entry point wired to the Control-rooted main scene.
extends Control

var _label_tile: Label
var _label_roll: Label


func _ready() -> void:
	await get_tree().process_frame

	var dice_roller: DiceRoller = $DiceRoller if has_node("DiceRoller") else null
	var player:      Player     = $Player     if has_node("Player")     else null
	var button_roll: Button     = $ButtonRoll
	_label_tile                 = $LabelTile
	_label_roll                 = $LabelRoll

	if dice_roller and player:
		dice_roller.rolled.connect(player.move_player)
		dice_roller.rolled.connect(_on_rolled)
		player.tile_landed.connect(_on_tile_landed)
		button_roll.pressed.connect(dice_roller.roll)
	else:
		# No game logic nodes yet — button just flashes the label so we know it works.
		button_roll.pressed.connect(_on_test_press)


func _on_test_press() -> void:
	_label_roll.text = "Roll: (tap works!)"


func _on_rolled(steps: int) -> void:
	_label_roll.text = "Roll: %d" % steps


func _on_tile_landed(tile: Dictionary) -> void:
	_label_tile.text = "Tile: %s" % tile.get("name", "—")
