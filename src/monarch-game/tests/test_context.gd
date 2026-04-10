## test_context.gd
## Minimal assertion helpers for headless tests.

extends RefCounted

var assertions: int = 0
var failures: int = 0


func assert_true(condition: bool, message: String = "") -> void:
	assertions += 1
	if not condition:
		failures += 1
		push_error("[Test] assert_true failed: %s" % (message if not message.is_empty() else "(no message)"))


func assert_eq(actual, expected, message: String = "") -> void:
	assertions += 1
	if actual != expected:
		failures += 1
		push_error("[Test] assert_eq failed: %s (actual=%s expected=%s)" % [
			(message if not message.is_empty() else "(no message)"),
			str(actual),
			str(expected),
		])

