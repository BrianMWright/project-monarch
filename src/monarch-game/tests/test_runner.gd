## test_runner.gd
## Runs all test_*.gd scripts under res://tests and exits non-zero on failure.

extends SceneTree

const TEST_DIR := "res://tests"

var _ctx


func _initialize() -> void:
	# Preload key scripts so class_name types are registered before tests compile.
	preload("res://BoardData.gd")
	preload("res://game/rng_service.gd")
	preload("res://game/deck.gd")
	preload("res://game/player_state.gd")
	preload("res://game/ai_agent.gd")
	preload("res://game/game_state.gd")

	_ctx = preload("res://tests/test_context.gd").new()

	var test_files := _find_test_files()
	print("[Tests] Found %d test file(s)." % test_files.size())

	for path in test_files:
		_run_one(path)

	if _ctx.failures > 0:
		print("[Tests] FAIL (%d failures, %d assertions)" % [_ctx.failures, _ctx.assertions])
		quit(1)
	else:
		print("[Tests] PASS (%d assertions)" % _ctx.assertions)
		quit(0)


func _find_test_files() -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(TEST_DIR)
	if dir == null:
		push_error("[Tests] Missing directory: %s" % TEST_DIR)
		return out

	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name.is_empty():
			break
		if dir.current_is_dir():
			continue
		if not name.begins_with("test_"):
			continue
		if name == "test_runner.gd" or name == "test_context.gd":
			continue
		if not name.ends_with(".gd"):
			continue
		out.append("%s/%s" % [TEST_DIR, name])
	dir.list_dir_end()

	out.sort()
	return out


func _run_one(path: String) -> void:
	print("[Tests] Running %s" % path)
	var script = load(path)
	if script == null:
		_ctx.assert_true(false, "Failed to load %s" % path)
		return

	var instance = script.new()
	if not instance.has_method("run"):
		_ctx.assert_true(false, "%s: missing run(ctx) method" % path)
		return

	instance.run(_ctx)
	if instance is Node:
		instance.queue_free()

