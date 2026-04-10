## rng_service.gd
## Deterministic RNG using a pure GDScript LCG (Knuth MMIX).
## Produces identical sequences for the same seed regardless of Godot instance order.

class_name RngService
extends RefCounted

var seed: int
var _state: int


func _init(p_seed: int) -> void:
	seed = p_seed
	_state = p_seed if p_seed != 0 else 1


func reseed(p_seed: int) -> void:
	seed = p_seed
	_state = p_seed if p_seed != 0 else 1


func _next() -> int:
	# Knuth MMIX LCG — deterministic, wraps on int64 overflow
	_state = _state * 6364136223846793005 + 1442695040888963407
	return _state


func randi_range(min_inclusive: int, max_inclusive: int) -> int:
	var range_size: int = max_inclusive - min_inclusive + 1
	var pos: int = _next() & 0x7FFFFFFFFFFFFFFF
	return min_inclusive + (pos % range_size)


func randf() -> float:
	var pos: int = _next() & 0x7FFFFFFFFFFFFFFF
	return float(pos) / float(0x7FFFFFFFFFFFFFFF)


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
