## deck.gd
## Deterministic deck (Chance / Community Chest).

class_name Deck
extends RefCounted

var _cards: Array[Dictionary] = []
var _index: int = 0


func reset(cards: Array[Dictionary], rng: RngService) -> void:
	_cards = []
	for c in cards:
		_cards.append(c)
	_cards = rng.shuffle_array(_cards)
	_index = 0


func draw() -> Dictionary:
	if _cards.is_empty():
		return {}

	var card: Dictionary = _cards[_index]
	_index = (_index + 1) % _cards.size()
	return card

