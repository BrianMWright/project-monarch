## control.gd
## Entry point wired to the Control-rooted main scene.
extends Control

var _label_tile: Label
var _label_balance: Label
var _label_roll: Label
var _label_status: Label


func _ready() -> void:
	push_error("[Control] _ready entered, size=%s viewport=%s" % [str(size), str(get_viewport_rect())])
	randomize()

	# Force the root Control to fill the viewport.
	# On Android the layout pass may not have completed when _ready fires.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	push_error("[Control] after force-resize size=%s" % str(size))

	await get_tree().process_frame

	var dice_roller: DiceRoller = $DiceRoller if has_node("DiceRoller") else null
	var player:      Player     = $Player     if has_node("Player")     else null
	var button_roll: Button     = $ButtonRoll
	_label_tile                 = $LabelTile
	_label_balance              = $LabelBalance
	_label_roll                 = $LabelRoll
	_label_status               = $LabelStatus

	if dice_roller and player:
		if player.board_data == null:
			player.board_data = BoardData.new()

		player.reset_state()
		dice_roller.rolled.connect(player.move_player)
		dice_roller.rolled.connect(_on_rolled)
		player.tile_landed.connect(_on_tile_landed)
		player.balance_changed.connect(_on_balance_changed)
		player.turn_resolved.connect(_on_turn_resolved)
		button_roll.pressed.connect(dice_roller.roll)
		_on_balance_changed(player.balance)
		_on_tile_landed(player.board_data.get_tile(player.current_tile_index))
	else:
		# No game logic nodes yet — button just flashes the label so we know it works.
		button_roll.pressed.connect(_on_test_press)


func _on_test_press() -> void:
	_label_roll.text = "Roll: (tap works!)"
	_label_status.text = "Status: Gameplay nodes are missing."


func _on_rolled(steps: int) -> void:
	_label_roll.text = "Roll: %d" % steps


func _on_tile_landed(tile: Dictionary) -> void:
	_label_tile.text = "Tile: %s" % tile.get("name", "—")
	var description: String = tile.get("description", "")
	if description.is_empty():
		_label_status.text = "Status: Landed on %s." % tile.get("name", "—")
	else:
		_label_status.text = "Status: %s" % description


func _on_balance_changed(balance: int) -> void:
	_label_balance.text = "Balance: $%d" % balance


func _on_turn_resolved(summary: String) -> void:
	_label_status.text = "Status: %s" % summary
