## BoardData.gd
## Holds static tile definitions for the game board.

class_name BoardData
extends Resource

const tiles: Array[Dictionary] = [
	{ "name": "Go",              "type": "go"       },
	{ "name": "Mediterranean",   "type": "property" },
	{ "name": "Community Chest", "type": "chest"    },
	{ "name": "Baltic Avenue",   "type": "property" },
]

func get_tile(index: int) -> Dictionary:
	return tiles[index % tiles.size()]

func get_tile_count() -> int:
	return tiles.size()
