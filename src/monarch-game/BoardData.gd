## BoardData.gd
## Holds static tile definitions for a classic 40-space board (v1).
##
## Notes:
## - This is intentionally isolated so it can be swapped later (e.g. to reduce IP risk).
## - Rents are base (unimproved) rent only; monopoly doubles rent in the rules engine.
## - Houses/hotels, trading, and mortgages are out of scope for v1.

class_name BoardData
extends Resource

const JAIL_INDEX := 10
const RAILROADS: Array[int] = [5, 15, 25, 35]
const UTILITIES: Array[int] = [12, 28]
const GROUP_INDICES := {
	"brown": [1, 3],
	"light_blue": [6, 8, 9],
	"pink": [11, 13, 14],
	"orange": [16, 18, 19],
	"red": [21, 23, 24],
	"yellow": [26, 27, 29],
	"green": [31, 32, 34],
	"dark_blue": [37, 39],
}

const tiles: Array[Dictionary] = [
	{"index": 0, "name": "Go", "type": "go", "description": "Collect $200 when you pass."},
	{"index": 1, "name": "Mediterranean Avenue", "type": "property", "group": "brown", "price": 60, "base_rent": 2},
	{"index": 2, "name": "Community Chest", "type": "chest"},
	{"index": 3, "name": "Baltic Avenue", "type": "property", "group": "brown", "price": 60, "base_rent": 4},
	{"index": 4, "name": "Income Tax", "type": "tax", "tax": 200},
	{"index": 5, "name": "Reading Railroad", "type": "railroad", "price": 200},
	{"index": 6, "name": "Oriental Avenue", "type": "property", "group": "light_blue", "price": 100, "base_rent": 6},
	{"index": 7, "name": "Chance", "type": "chance"},
	{"index": 8, "name": "Vermont Avenue", "type": "property", "group": "light_blue", "price": 100, "base_rent": 6},
	{"index": 9, "name": "Connecticut Avenue", "type": "property", "group": "light_blue", "price": 120, "base_rent": 8},
	{"index": 10, "name": "Jail / Just Visiting", "type": "jail"},
	{"index": 11, "name": "St. Charles Place", "type": "property", "group": "pink", "price": 140, "base_rent": 10},
	{"index": 12, "name": "Electric Company", "type": "utility", "price": 150},
	{"index": 13, "name": "States Avenue", "type": "property", "group": "pink", "price": 140, "base_rent": 10},
	{"index": 14, "name": "Virginia Avenue", "type": "property", "group": "pink", "price": 160, "base_rent": 12},
	{"index": 15, "name": "Pennsylvania Railroad", "type": "railroad", "price": 200},
	{"index": 16, "name": "St. James Place", "type": "property", "group": "orange", "price": 180, "base_rent": 14},
	{"index": 17, "name": "Community Chest", "type": "chest"},
	{"index": 18, "name": "Tennessee Avenue", "type": "property", "group": "orange", "price": 180, "base_rent": 14},
	{"index": 19, "name": "New York Avenue", "type": "property", "group": "orange", "price": 200, "base_rent": 16},
	{"index": 20, "name": "Free Parking", "type": "free_parking"},
	{"index": 21, "name": "Kentucky Avenue", "type": "property", "group": "red", "price": 220, "base_rent": 18},
	{"index": 22, "name": "Chance", "type": "chance"},
	{"index": 23, "name": "Indiana Avenue", "type": "property", "group": "red", "price": 220, "base_rent": 18},
	{"index": 24, "name": "Illinois Avenue", "type": "property", "group": "red", "price": 240, "base_rent": 20},
	{"index": 25, "name": "B. & O. Railroad", "type": "railroad", "price": 200},
	{"index": 26, "name": "Atlantic Avenue", "type": "property", "group": "yellow", "price": 260, "base_rent": 22},
	{"index": 27, "name": "Ventnor Avenue", "type": "property", "group": "yellow", "price": 260, "base_rent": 22},
	{"index": 28, "name": "Water Works", "type": "utility", "price": 150},
	{"index": 29, "name": "Marvin Gardens", "type": "property", "group": "yellow", "price": 280, "base_rent": 24},
	{"index": 30, "name": "Go To Jail", "type": "go_to_jail"},
	{"index": 31, "name": "Pacific Avenue", "type": "property", "group": "green", "price": 300, "base_rent": 26},
	{"index": 32, "name": "North Carolina Avenue", "type": "property", "group": "green", "price": 300, "base_rent": 26},
	{"index": 33, "name": "Community Chest", "type": "chest"},
	{"index": 34, "name": "Pennsylvania Avenue", "type": "property", "group": "green", "price": 320, "base_rent": 28},
	{"index": 35, "name": "Short Line", "type": "railroad", "price": 200},
	{"index": 36, "name": "Chance", "type": "chance"},
	{"index": 37, "name": "Park Place", "type": "property", "group": "dark_blue", "price": 350, "base_rent": 35},
	{"index": 38, "name": "Luxury Tax", "type": "tax", "tax": 100},
	{"index": 39, "name": "Boardwalk", "type": "property", "group": "dark_blue", "price": 400, "base_rent": 50},
]


func get_tile(index: int) -> Dictionary:
	return tiles[index % tiles.size()]


func get_tile_count() -> int:
	return tiles.size()


func get_jail_index() -> int:
	return JAIL_INDEX


func get_railroad_indices() -> Array[int]:
	return RAILROADS.duplicate()


func get_utility_indices() -> Array[int]:
	return UTILITIES.duplicate()


func get_property_group_indices(group: String) -> Array[int]:
	if GROUP_INDICES.has(group):
		var indices: Array = GROUP_INDICES[group]
		return indices.duplicate()
	return []
