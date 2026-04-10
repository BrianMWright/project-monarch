extends RefCounted

const GameState := preload("res://game/game_state.gd")
const AiAgent := preload("res://game/ai_agent.gd")

func run(ctx) -> void:
	var snap: Dictionary = _simulate(999, 6)
	ctx.assert_true(snap.get("seed", -1) == 999, "seed preserved")
	var players: Array = snap.get("players", [])
	ctx.assert_true(players.size() == 2, "simulation has 2 players")
	ctx.assert_true(int(players[0].get("cash", -1)) >= 0, "player 1 solvent")
	ctx.assert_true(int(players[1].get("cash", -1)) >= 0, "player 2 solvent")

	_test_double_roll_buy_continues_turn(ctx)
	_test_double_roll_auction_continues_turn(ctx)
	_test_double_roll_then_regular_roll_ends_turn(ctx)
	_test_unowned_property_prompts_buy_or_auction(ctx)
	_test_doubles_keep_same_player_turn_after_owned_tile(ctx)
	_test_three_doubles_send_player_to_jail(ctx)


func _simulate(p_seed: int, turns: int) -> Dictionary:
	var gs: GameState = GameState.new()
	gs.setup(true, true, p_seed)
	var ai: AiAgent = AiAgent.new()

	var safety: int = 0
	while turns > 0 and gs.phase != GameState.Phase.GAME_OVER:
		gs.request_roll()
		safety += 1
		if safety > 5000:
			break
		while gs.phase == GameState.Phase.AWAIT_DECISION:
			var snap: Dictionary = gs.get_snapshot()
			var decision: Dictionary = snap.get("pending_decision", {})
			var action: Dictionary = ai.choose_action(decision)
			if str(decision.get("type", "")) == "END_TURN_CONFIRM":
				action = {"action": "end_turn"}
				turns -= 1
			gs.respond(action)
			safety += 1
			if safety > 5000:
				break

	return {
		"seed": gs.seed,
		"players": gs.get_snapshot().get("players", []),
		"owners": gs.get_snapshot().get("owners", {}),
	}


func _test_double_roll_buy_continues_turn(ctx) -> void:
	var gs: GameState = GameState.new()
	gs.setup(false, true, 1)
	gs.set_test_forced_rolls([[3, 3]])
	gs.request_roll()

	var snap: Dictionary = gs.get_snapshot()
	ctx.assert_eq(int(snap.get("phase", -1)), GameState.Phase.AWAIT_DECISION, "buy decision requested after double landing")
	ctx.assert_eq(str(snap.get("pending_decision", {}).get("type", "")), "BUY_OR_AUCTION", "buy decision type")

	gs.respond({"action": "buy"})
	snap = gs.get_snapshot()
	ctx.assert_eq(int(snap.get("phase", -1)), GameState.Phase.AWAIT_ROLL, "same player keeps bonus roll after buy")
	ctx.assert_true(snap.get("pending_decision", {}).is_empty(), "no pending decision after buy")
	ctx.assert_eq(int(snap.get("current_player_index", -1)), 0, "current player remains Player 1")


func _test_double_roll_auction_continues_turn(ctx) -> void:
	var gs: GameState = GameState.new()
	gs.setup(false, true, 1)
	gs.set_test_forced_rolls([[3, 3]])
	gs.request_roll()

	gs.respond({"action": "auction"})
	var snap: Dictionary = gs.get_snapshot()
	ctx.assert_eq(str(snap.get("pending_decision", {}).get("type", "")), "AUCTION_BID_OR_PASS", "auction started")

	gs.respond({"action": "pass"})
	gs.respond({"action": "pass"})
	var after_auction: Dictionary = gs.get_snapshot()
	ctx.assert_eq(int(after_auction.get("phase", -1)), GameState.Phase.AWAIT_ROLL, "same player keeps bonus roll after auction")
	ctx.assert_true(after_auction.get("pending_decision", {}).is_empty(), "auction leaves no pending decision")
	ctx.assert_eq(int(after_auction.get("current_player_index", -1)), 0, "current player remains Player 1 after auction")


func _test_double_roll_then_regular_roll_ends_turn(ctx) -> void:
	var gs: GameState = GameState.new()
	gs.setup(false, true, 1)
	gs.set_test_forced_rolls([[3, 3], [2, 3]])

	gs.request_roll()
	gs.respond({"action": "buy"})
	var snap: Dictionary = gs.get_snapshot()
	ctx.assert_eq(int(snap.get("phase", -1)), GameState.Phase.AWAIT_ROLL, "bonus roll available after first double")

	gs.request_roll()
	snap = gs.get_snapshot()
	ctx.assert_eq(int(snap.get("phase", -1)), GameState.Phase.AWAIT_DECISION, "non-double turn resolves to end-turn confirmation")
	ctx.assert_eq(str(snap.get("pending_decision", {}).get("type", "")), "END_TURN_CONFIRM", "turn ends after non-double bonus roll")


func _test_unowned_property_prompts_buy_or_auction(ctx) -> void:
	var gs: GameState = GameState.new()
	gs.setup(false, true, 1)
	gs.set_test_forced_rolls([[3, 3]])
	gs.request_roll()

	var snap: Dictionary = gs.get_snapshot()
	ctx.assert_eq(str(snap.get("pending_decision", {}).get("type", "")), "BUY_OR_AUCTION", "unowned property prompts buy or auction")
	ctx.assert_eq(str(snap.get("pending_decision", {}).get("tile_name", "")), "Oriental Avenue", "forced roll lands on expected tile")


func _test_doubles_keep_same_player_turn_after_owned_tile(ctx) -> void:
	var gs: GameState = GameState.new()
	gs.setup(false, true, 1)
	gs.owners[6] = 1
	gs.set_test_forced_rolls([[3, 3], [2, 3]])
	gs.request_roll()
	gs.respond({"action": "buy"})
	var snap: Dictionary = gs.get_snapshot()
	ctx.assert_eq(int(snap.get("phase", -1)), GameState.Phase.AWAIT_ROLL, "still same player after first doubles decision")

	gs.request_roll()
	snap = gs.get_snapshot()
	ctx.assert_eq(int(snap.get("phase", -1)), GameState.Phase.AWAIT_DECISION, "non-double resolves turn")
	ctx.assert_eq(str(snap.get("pending_decision", {}).get("type", "")), "END_TURN_CONFIRM", "owned-tile double still ends turn on non-double second roll")


func _test_three_doubles_send_player_to_jail(ctx) -> void:
	var gs: GameState = GameState.new()
	gs.setup(false, true, 1)
	gs.set_test_forced_rolls([[3, 3], [4, 4], [5, 5]])
	gs.request_roll()
	gs.respond({"action": "buy"})
	gs.request_roll()
	gs.respond({"action": "buy"})
	gs.request_roll()

	var snap: Dictionary = gs.get_snapshot()
	ctx.assert_eq(int(snap.get("phase", -1)), GameState.Phase.AWAIT_DECISION, "third doubles ends in end-turn decision")
	ctx.assert_eq(str(snap.get("pending_decision", {}).get("type", "")), "END_TURN_CONFIRM", "third doubles forces turn end")
