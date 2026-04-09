## BoardData.gd
## Holds static tile definitions for the game board.

class_name BoardData
extends Resource

const tiles: Array[Dictionary] = [
	{
		"name": "Go",
		"type": "go",
		"description": "Collect a small starting bonus.",
		"amount": 200,
	},
	{
		"name": "Mediterranean",
		"type": "property",
		"description": "Pay rent on a modest property.",
		"amount": -60,
	},
	{
		"name": "Community Chest",
		"type": "chest",
		"description": "Receive a neighborhood reward.",
		"amount": 120,
	},
	{
		"name": "Baltic Avenue",
		"type": "property",
		"description": "Pay rent on a second property.",
		"amount": -80,
	},
]

func get_tile(index: int) -> Dictionary:
	return tiles[index % tiles.size()]

func get_tile_count() -> int:
	return tiles.size()
