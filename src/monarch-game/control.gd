## control.gd
## Entry point wired to the Control-rooted main scene.
extends Control

var _label_tile: Label
var _label_balance: Label
var _label_roll: Label
var _label_status: Label
var _button_roll: Button
var _button_menu: Button
var _pause_menu


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
	_button_roll                = $ButtonRoll
	_label_tile                 = $LabelTile
	_label_balance              = $LabelBalance
	_label_roll                 = $LabelRoll
	_label_status               = $LabelStatus
	_button_menu                = $ButtonMenu if has_node("ButtonMenu") else null
	_pause_menu                 = $PauseMenu if has_node("PauseMenu") else null

	if _button_menu and _pause_menu:
		_button_menu.pressed.connect(_toggle_menu)
		_pause_menu.resume_requested.connect(_close_menu)
		_pause_menu.main_menu_requested.connect(_on_main_menu_requested)
		_pause_menu.quit_requested.connect(_on_quit_requested)

	if dice_roller and player:
		if player.board_data == null:
			player.board_data = BoardData.new()

		player.reset_state()
		dice_roller.rolled.connect(player.move_player)
		dice_roller.rolled.connect(_on_rolled)
		player.tile_landed.connect(_on_tile_landed)
		player.balance_changed.connect(_on_balance_changed)
		player.turn_resolved.connect(_on_turn_resolved)
		_button_roll.pressed.connect(dice_roller.roll)
		_on_balance_changed(player.balance)
		_on_tile_landed(player.board_data.get_tile(player.current_tile_index))
	else:
		# No game logic nodes yet — button just flashes the label so we know it works.
		_button_roll.pressed.connect(_on_test_press)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _pause_menu and not _pause_menu.visible:
			_open_menu()
		get_viewport().set_input_as_handled()


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


func _toggle_menu() -> void:
	if _pause_menu == null:
		return

	if _pause_menu.visible:
		_close_menu()
	else:
		_open_menu()


func _open_menu() -> void:
	if _pause_menu == null:
		return
	_pause_menu.open()
	_button_roll.disabled = true


func _close_menu() -> void:
	if _pause_menu == null:
		return
	_pause_menu.close()
	_button_roll.disabled = false


func _on_main_menu_requested() -> void:
	_close_menu()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _on_quit_requested() -> void:
	_close_menu()
	get_tree().quit()
