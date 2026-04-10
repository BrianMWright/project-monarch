extends RefCounted


func run(ctx) -> void:
	var snapshot_a := _simulate(999, 12)
	var snapshot_b := _simulate(999, 12)
	ctx.assert_eq(snapshot_a, snapshot_b, "Simulation snapshot matches for same seed")


func _simulate(seed: int, turns: int) -> Dictionary:
	var gs := GameState.new()
	gs.setup(true, true, seed)
	var ai := AiAgent.new()

	var safety: int = 0
	while turns > 0 and gs.phase != GameState.Phase.GAME_OVER:
		gs.request_roll()
		safety += 1
		if safety > 5000:
			break

		while gs.phase == GameState.Phase.AWAIT_DECISION:
			var snap := gs.get_snapshot()
			var decision: Dictionary = snap.get("pending_decision", {})
			var action := ai.choose_action(decision)
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

