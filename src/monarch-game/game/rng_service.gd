## rng_service.gd
## Deterministic RNG wrapper for dice, decks, and AI decisions.

class_name RngService
extends RefCounted

var seed: int
var _rng: RandomNumberGenerator


func _init(p_seed: int) -> void:
	seed = p_seed
	_rng = RandomNumberGenerator.new()
	_rng.seed = seed


func randi_range(min_inclusive: int, max_inclusive: int) -> int:
	return _rng.randi_range(min_inclusive, max_inclusive)


func randf() -> float:
	return _rng.randf()


func roll_d6() -> int:
	return randi_range(1, 6)


func shuffle_array(items: Array) -> Array:
	var out := items.duplicate()
	if out.size() <= 1:
		return out

	for i in range(out.size() - 1, 0, -1):
		var j := randi_range(0, i)
		var tmp: Variant = out[i]
		out[i] = out[j]
		out[j] = tmp
	return out

