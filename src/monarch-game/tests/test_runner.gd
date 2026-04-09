## test_runner.gd
## Headless test runner: `godot --headless --path src/monarch-game --script res://tests/test_runner.gd`
extends SceneTree

const TEST_GLOB_PREFIX := "res://tests/test_"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ctx_script := load("res://tests/test_context.gd")
	var ctx = ctx_script.new()

	var test_paths := _find_test_scripts()
	test_paths.sort()

	var tests_run := 0
	var tests_failed := 0

	print("[Tests] Found %d test file(s)." % test_paths.size())

	for path in test_paths:
		tests_run += 1
		var ok := _run_one(path, ctx)
		if not ok:
			tests_failed += 1

	if ctx.failures.is_empty():
		print("[Tests] PASS (%d tests, %d assertions)" % [tests_run, ctx.assertions_run])
		quit(0)
		return

	print("[Tests] FAIL (%d failing test file(s), %d total failures, %d assertions)" % [
		tests_failed,
		ctx.failures.size(),
		ctx.assertions_run,
	])
	for f in ctx.failures:
		push_error("[Tests] " + f)
	quit(1)


func _find_test_scripts() -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open("res://tests")
	if dir == null:
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
		if not name.ends_with(".gd"):
			continue
		out.append("res://tests/%s" % name)
	dir.list_dir_end()
	return out


func _run_one(path: String, ctx) -> bool:
	print("[Tests] Running %s" % path)
	var script := load(path)
	if script == null:
		ctx.failures.append("%s: could not load" % path)
		return false

	var test_obj = script.new()
	if test_obj == null:
		ctx.failures.append("%s: could not instantiate" % path)
		return false

	if not test_obj.has_method("run"):
		ctx.failures.append("%s: missing run(ctx) method" % path)
		return false

	var before := ctx.failures.size()
	test_obj.run(ctx)
	var after := ctx.failures.size()
	return after == before

