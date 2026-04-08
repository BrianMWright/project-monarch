## BoardData.gd
## Holds static tile definitions for the game board.
##
## Live Ops note: Replace the static `tiles` array with a remote-config fetch
## (e.g. a JSON payload from your CDN) to push board changes without a full
## app-store release.

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
