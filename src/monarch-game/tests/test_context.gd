## test_context.gd
## Minimal, dependency-free test helpers for running GDScript logic tests headlessly.
extends RefCounted

var failures: Array[String] = []
var assertions_run: int = 0


func assert_true(condition: bool, message: String) -> void:
	assertions_run += 1
	if not condition:
		failures.append(message)


func assert_false(condition: bool, message: String) -> void:
	assert_true(not condition, message)


func assert_eq(actual, expected, message: String) -> void:
	assertions_run += 1
	if actual != expected:
		failures.append("%s (actual=%s expected=%s)" % [message, str(actual), str(expected)])


func assert_ne(actual, expected, message: String) -> void:
	assertions_run += 1
	if actual == expected:
		failures.append("%s (actual=%s expected!=%s)" % [message, str(actual), str(expected)])

