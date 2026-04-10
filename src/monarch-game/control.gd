## control.gd
## Entry point wired to the Control-rooted main scene.
extends Control

var _game_state: GameState
var _ai_agent: AiAgent

var _label_tile: Label
var _label_balance: Label
var _label_roll: Label
var _label_status: Label
var _label_turn: Label
var _button_roll: Button
var _decision_bar: HBoxContainer
var _button_buy: Button
var _button_auction: Button
var _button_bid: Button
var _button_pass: Button
var _button_pay_fine: Button
var _button_jail_roll: Button
var _button_use_card: Button
var _button_end_turn: Button
var _button_menu: Button
var _pause_menu


func _ready() -> void:
	await get_tree().process_frame

	_button_roll                = $ButtonRoll
	_label_tile                 = $LabelTile
	_label_balance              = $LabelBalance
	_label_roll                 = $LabelRoll
	_label_status               = $LabelStatus
	_label_turn                 = $LabelTurn
	_decision_bar               = $DecisionBar
	_button_buy                 = $DecisionBar/ButtonBuy
	_button_auction             = $DecisionBar/ButtonAuction
	_button_bid                 = $DecisionBar/ButtonBid
	_button_pass                = $DecisionBar/ButtonPass
	_button_pay_fine            = $DecisionBar/ButtonPayFine
	_button_jail_roll           = $DecisionBar/ButtonJailRoll
	_button_use_card            = $DecisionBar/ButtonUseCard
	_button_end_turn            = $DecisionBar/ButtonEndTurn
	_button_menu                = $ButtonMenu if has_node("ButtonMenu") else null
	_pause_menu                 = $PauseMenu if has_node("PauseMenu") else null

	if _button_menu and _pause_menu:
		_button_menu.pressed.connect(_toggle_menu)
		_pause_menu.resume_requested.connect(_close_menu)
		_pause_menu.main_menu_requested.connect(_on_main_menu_requested)
		_pause_menu.quit_requested.connect(_on_quit_requested)

	_button_roll.pressed.connect(_on_roll_pressed)
	_button_buy.pressed.connect(func() -> void: _game_state.respond({"action": "buy"}))
	_button_auction.pressed.connect(func() -> void: _game_state.respond({"action": "auction"}))
	_button_bid.pressed.connect(_on_bid_pressed)
	_button_pass.pressed.connect(func() -> void: _game_state.respond({"action": "pass"}))
	_button_pay_fine.pressed.connect(func() -> void: _game_state.respond({"action": "pay_fine"}))
	_button_jail_roll.pressed.connect(func() -> void: _game_state.respond({"action": "roll"}))
	_button_use_card.pressed.connect(func() -> void: _game_state.respond({"action": "use_card"}))
	_button_end_turn.pressed.connect(func() -> void: _game_state.respond({"action": "end_turn"}))

	_game_state = GameState.new()
	_ai_agent = AiAgent.new()

	_game_state.state_changed.connect(_on_state_changed)
	_game_state.decision_requested.connect(_on_decision_requested)
	_game_state.log_line.connect(_on_log_line)
	_game_state.game_over.connect(_on_game_over)

	var fixed_seed_enabled := Settings.fixed_seed_enabled
	var fixed_seed_value := Settings.fixed_seed_value
	var override_seed := _get_cmdline_seed_override()
	if override_seed != null:
		fixed_seed_enabled = true
		fixed_seed_value = int(override_seed)

	var vs_ai := Settings.game_mode == Settings.GameMode.VS_AI
	_game_state.setup(vs_ai, fixed_seed_enabled, fixed_seed_value)

	_set_decision_ui({})


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _pause_menu and not _pause_menu.visible:
			_open_menu()
		get_viewport().set_input_as_handled()


func _on_roll_pressed() -> void:
	_game_state.request_roll()


func _on_bid_pressed() -> void:
	var snap := _game_state.get_snapshot()
	var decision: Dictionary = snap.get("pending_decision", {})
	var current_bid := int(decision.get("current_bid", 0))
	var amount := current_bid + 10
	_game_state.respond({"action": "bid", "amount": amount})


func _on_state_changed(snapshot: Dictionary) -> void:
	var current_index := int(snapshot.get("current_player_index", 0))
	var players: Array = snapshot.get("players", [])
	if players.size() >= 2:
		var p1: Dictionary = players[0]
		var p2: Dictionary = players[1]
		_label_balance.text = "P1: $%d   P2: $%d" % [int(p1.get("cash", 0)), int(p2.get("cash", 0))]

	if current_index < players.size():
		var p: Dictionary = players[current_index]
		var type_label := "AI" if int(p.get("type", 0)) == PlayerState.PlayerType.AI else "Human"
		_label_turn.text = "Turn: %s (%s)" % [str(p.get("name", "Player")), type_label]
		var pos := int(p.get("position", 0))
		var tile := _game_state.board_data.get_tile(pos)
		_label_tile.text = "Tile: %s" % str(tile.get("name", "—"))

	var roll := snapshot.get("last_roll", [0, 0])
	if roll is Array and roll.size() >= 2:
		_label_roll.text = "Roll: %d + %d" % [int(roll[0]), int(roll[1])]

	var decision: Dictionary = snapshot.get("pending_decision", {})
	_set_decision_ui(decision)


func _on_decision_requested(decision: Dictionary) -> void:
	_set_decision_ui(decision)

	var snap := _game_state.get_snapshot()
	var players: Array = snap.get("players", [])
	var decision_player_index := int(decision.get("bidder_index", snap.get("current_player_index", 0)))
	if decision_player_index >= 0 and decision_player_index < players.size():
		var p: Dictionary = players[decision_player_index]
		var is_ai := int(p.get("type", 0)) == PlayerState.PlayerType.AI
		if is_ai:
			_label_status.text = "Status: AI thinking..."
			await get_tree().process_frame
			var action := _ai_agent.choose_action(decision)
			_game_state.respond(action)


func _on_log_line(message: String) -> void:
	_label_status.text = "Status: %s" % message


func _on_game_over(winner_index: int) -> void:
	_label_status.text = "Status: Game over. Winner: Player %d" % (winner_index + 1)
	_button_roll.disabled = true
	_set_decision_ui({})


func _set_decision_ui(decision: Dictionary) -> void:
	var decision_type := str(decision.get("type", ""))

	_button_buy.visible = false
	_button_auction.visible = false
	_button_bid.visible = false
	_button_pass.visible = false
	_button_pay_fine.visible = false
	_button_jail_roll.visible = false
	_button_use_card.visible = false
	_button_end_turn.visible = false

	if decision_type.is_empty():
		_decision_bar.visible = false
		_button_roll.disabled = false
		return

	_decision_bar.visible = true
	_button_roll.disabled = true

	match decision_type:
		"BUY_OR_AUCTION":
			_button_buy.visible = true
			_button_auction.visible = true
		"AUCTION_BID_OR_PASS":
			_button_bid.visible = true
			_button_pass.visible = true
		"JAIL_CHOICE":
			_button_pay_fine.visible = true
			_button_jail_roll.visible = true
			_button_use_card.visible = int(decision.get("get_out_cards", 0)) > 0
		"END_TURN_CONFIRM":
			_button_end_turn.visible = true
		_:
			_button_end_turn.visible = true


func _get_cmdline_seed_override() -> Variant:
	var args := OS.get_cmdline_user_args()
	for a in args:
		var s := str(a)
		if s.begins_with("--fixed-seed="):
			return int(s.get_slice("=", 1))
	return null


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
