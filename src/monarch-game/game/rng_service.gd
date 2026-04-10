## rng_service.gd
## Deterministic RNG using a 32-bit LCG (Numerical Recipes).
## All arithmetic stays within int64 range — no overflow, no float conversion.

extends RefCounted

var seed: int
var _state: int


func _init(p_seed: int) -> void:
	seed = p_seed
	_state = p_seed & 0xFFFFFFFF if p_seed != 0 else 1


func reseed(p_seed: int) -> void:
	seed = p_seed
	_state = p_seed & 0xFFFFFFFF if p_seed != 0 else 1


func _next() -> int:
	_state = (_state * 1664525 + 1013904223) & 0xFFFFFFFF
	return _state


func randi_range(min_inclusive: int, max_inclusive: int) -> int:
	var range_size: int = max_inclusive - min_inclusive + 1
	return min_inclusive + (_next() % range_size)


func randf() -> float:
	return float(_next()) / 4294967296.0


func roll_d6() -> int:
	return randi_range(1, 6)


func shuffle_array(items: Array) -> Array:
	var out: Array = items.duplicate()
	if out.size() <= 1:
		return out
	for i in range(out.size() - 1, 0, -1):
		var j: int = randi_range(0, i)
		var tmp: Variant = out[i]
		out[i] = out[j]
		out[j] = tmp
	return out
