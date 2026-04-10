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
