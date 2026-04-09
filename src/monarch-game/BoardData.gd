## BoardData.gd
## Holds static tile definitions for the game board.

class_name BoardData
extends Resource

const tiles: Array[Dictionary] = [
	{
		"name": "Go",
		"type": "go",
		"description": "Corner square. Collect a small starting bonus.",
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
	{
		"name": "Income Tax",
		"type": "tax",
		"description": "Pay taxes.",
		"amount": -100,
	},
	{
		"name": "Reading Railroad",
		"type": "railroad",
		"description": "Pay a railroad fee.",
		"amount": -50,
	},
	{
		"name": "Oriental Avenue",
		"type": "property",
		"description": "Pay rent on Oriental Avenue.",
		"amount": -100,
	},
	{
		"name": "Chance",
		"type": "chance",
		"description": "A lucky break! Receive a small bonus.",
		"amount": 50,
	},
	{
		"name": "Vermont Avenue",
		"type": "property",
		"description": "Pay rent on Vermont Avenue.",
		"amount": -100,
	},
	{
		"name": "Connecticut Avenue",
		"type": "property",
		"description": "Pay rent on Connecticut Avenue.",
		"amount": -120,
	},
	{
		"name": "Jail",
		"type": "jail",
		"description": "Corner square. Just visiting.",
		"amount": 0,
	},
	{
		"name": "St. Charles Place",
		"type": "property",
		"description": "Pay rent on St. Charles Place.",
		"amount": -140,
	},
	{
		"name": "Electric Company",
		"type": "utility",
		"description": "Pay the utility bill.",
		"amount": -75,
	},
	{
		"name": "States Avenue",
		"type": "property",
		"description": "Pay rent on States Avenue.",
		"amount": -140,
	},
	{
		"name": "Virginia Avenue",
		"type": "property",
		"description": "Pay rent on Virginia Avenue.",
		"amount": -160,
	},
	{
		"name": "Pennsylvania Railroad",
		"type": "railroad",
		"description": "Pay a railroad fee.",
		"amount": -50,
	},
	{
		"name": "St. James Place",
		"type": "property",
		"description": "Pay rent on St. James Place.",
		"amount": -180,
	},
	{
		"name": "Community Chest",
		"type": "chest",
		"description": "Receive a neighborhood reward.",
		"amount": 120,
	},
	{
		"name": "Tennessee Avenue",
		"type": "property",
		"description": "Pay rent on Tennessee Avenue.",
		"amount": -180,
	},
	{
		"name": "New York Avenue",
		"type": "property",
		"description": "Pay rent on New York Avenue.",
		"amount": -200,
	},
	{
		"name": "Free Parking",
		"type": "free_parking",
		"description": "Corner square. Take a breather.",
		"amount": 0,
	},
	{
		"name": "Kentucky Avenue",
		"type": "property",
		"description": "Pay rent on Kentucky Avenue.",
		"amount": -220,
	},
	{
		"name": "Chance",
		"type": "chance",
		"description": "A lucky break! Receive a small bonus.",
		"amount": 50,
	},
	{
		"name": "Indiana Avenue",
		"type": "property",
		"description": "Pay rent on Indiana Avenue.",
		"amount": -220,
	},
	{
		"name": "Illinois Avenue",
		"type": "property",
		"description": "Pay rent on Illinois Avenue.",
		"amount": -240,
	},
	{
		"name": "B&O Railroad",
		"type": "railroad",
		"description": "Pay a railroad fee.",
		"amount": -50,
	},
	{
		"name": "Atlantic Avenue",
		"type": "property",
		"description": "Pay rent on Atlantic Avenue.",
		"amount": -260,
	},
	{
		"name": "Ventnor Avenue",
		"type": "property",
		"description": "Pay rent on Ventnor Avenue.",
		"amount": -260,
	},
	{
		"name": "Water Works",
		"type": "utility",
		"description": "Pay the utility bill.",
		"amount": -75,
	},
	{
		"name": "Marvin Gardens",
		"type": "property",
		"description": "Pay rent on Marvin Gardens.",
		"amount": -280,
	},
	{
		"name": "Go To Jail",
		"type": "go_to_jail",
		"description": "Corner square. Go to jail (not implemented yet).",
		"amount": 0,
	},
	{
		"name": "Pacific Avenue",
		"type": "property",
		"description": "Pay rent on Pacific Avenue.",
		"amount": -300,
	},
	{
		"name": "North Carolina Avenue",
		"type": "property",
		"description": "Pay rent on North Carolina Avenue.",
		"amount": -300,
	},
	{
		"name": "Community Chest",
		"type": "chest",
		"description": "Receive a neighborhood reward.",
		"amount": 120,
	},
	{
		"name": "Pennsylvania Avenue",
		"type": "property",
		"description": "Pay rent on Pennsylvania Avenue.",
		"amount": -320,
	},
	{
		"name": "Short Line",
		"type": "railroad",
		"description": "Pay a railroad fee.",
		"amount": -50,
	},
	{
		"name": "Chance",
		"type": "chance",
		"description": "A lucky break! Receive a small bonus.",
		"amount": 50,
	},
	{
		"name": "Park Place",
		"type": "property",
		"description": "Pay rent on Park Place.",
		"amount": -350,
	},
	{
		"name": "Luxury Tax",
		"type": "tax",
		"description": "Pay luxury tax.",
		"amount": -100,
	},
	{
		"name": "Boardwalk",
		"type": "property",
		"description": "Pay rent on Boardwalk.",
		"amount": -400,
	},
]

func get_tile(index: int) -> Dictionary:
	return tiles[index % tiles.size()]

func get_tile_count() -> int:
	return tiles.size()
