## BoardData.gd
## Holds static tile definitions for the game board.
##
## Live Ops note: Replace the static `tiles` array with a remote-config fetch
## (e.g. a JSON payload from your CDN) to push board changes without a full
## app-store release.

class_name BoardData
extends Resource

# ---------------------------------------------------------------------------
# Tile registry
# Each Dictionary supports an arbitrary set of keys so new tile types
# (e.g. "event", "multiplier") can be introduced via Live Ops config
# without breaking existing entries.
# ---------------------------------------------------------------------------
const tiles: Array[Dictionary] = [
	{ "name": "Go",             "type": "go"       },
	{ "name": "Mediterranean",  "type": "property" },
	{ "name": "Community Chest","type": "chest"    },
	{ "name": "Baltic Avenue",  "type": "property" },
]


## Returns the tile Dictionary at [param index], wrapping around the board.
static func get_tile(index: int) -> Dictionary:
	return tiles[index % tiles.size()]
