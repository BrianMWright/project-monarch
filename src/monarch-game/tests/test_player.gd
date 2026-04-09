## test_player.gd
extends RefCounted

const BoardDataScript: Script = preload("res://BoardData.gd")
const PlayerScript: Script = preload("res://Player.gd")

func run(ctx) -> void:
	var board = BoardDataScript.new()
	var player = PlayerScript.new()
	player.board_data = board
	player.player_name = "TestPlayer"
	player.starting_balance = 1000

	var balance_events: Array[int] = []
	var summaries: Array[String] = []
	player.balance_changed.connect(func(b: int) -> void: balance_events.append(b))
	player.turn_resolved.connect(func(s: String) -> void: summaries.append(s))

	player.reset_state()
	ctx.assert_eq(player.current_tile_index, 0, "reset_state sets tile index to 0")
	ctx.assert_eq(player.balance, 1000, "reset_state sets balance to starting_balance")
	ctx.assert_true(balance_events.size() >= 1, "reset_state emits balance_changed")

	var start_index: int = int(player.current_tile_index)
	player.move_player(1)
	ctx.assert_eq(player.current_tile_index, (start_index + 1) % board.get_tile_count(), "move_player advances index and wraps")
	ctx.assert_true(summaries.size() >= 1, "move_player resolves tile and emits turn_resolved")
	ctx.assert_true(balance_events.size() >= 2, "move_player emits balance_changed when applying tile amount")

	# Amount on tile 1 is expected to be -60 per current prototype data.
	ctx.assert_ne(player.balance, 1000, "tile resolution should change balance when amount != 0")
