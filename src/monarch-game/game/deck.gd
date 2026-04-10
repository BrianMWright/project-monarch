## deck.gd
## Deterministic deck (Chance / Community Chest).

class_name Deck
extends RefCounted

const RngService := preload("res://game/rng_service.gd")

var _cards: Array = []
var _index: int = 0


func reset(cards: Array[Dictionary], rng: RngService) -> void:
	_cards = rng.shuffle_array(cards)
	_index = 0


func draw() -> Dictionary:
	if _cards.is_empty():
		return {}

	var card: Dictionary = _cards[_index]
	_index = (_index + 1) % _cards.size()
	return card
