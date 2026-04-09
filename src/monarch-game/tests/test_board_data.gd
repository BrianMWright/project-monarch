## test_board_data.gd
extends RefCounted

func run(ctx) -> void:
	var board_script: Script = load("res://BoardData.gd")
	ctx.assert_true(board_script != null, "BoardData.gd should load")
	if board_script == null:
		return
	ctx.assert_true(board_script.can_instantiate(), "BoardData.gd should compile")
	if not board_script.can_instantiate():
		return

	var board = board_script.new()

	ctx.assert_true(board.get_tile_count() > 0, "BoardData should have at least one tile")
	ctx.assert_eq(board.get_tile_count(), board.tiles.size(), "BoardData.get_tile_count matches tiles.size()")

	var first: Dictionary = board.get_tile(0)
	var wrapped: Dictionary = board.get_tile(board.get_tile_count())
	ctx.assert_eq(wrapped.get("name", ""), first.get("name", ""), "get_tile wraps around")

	for i in range(board.get_tile_count()):
		var t: Dictionary = board.get_tile(i)
		ctx.assert_true(t.has("name"), "tile[%d] has name" % i)
		ctx.assert_true(t.has("type"), "tile[%d] has type" % i)
