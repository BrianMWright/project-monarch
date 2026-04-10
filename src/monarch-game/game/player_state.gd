## player_state.gd
## Plain data model for a player.

class_name PlayerState
extends RefCounted

enum PlayerType { HUMAN, AI }

var player_name: String = "Player"
var player_type: int = PlayerType.HUMAN

var cash: int = 1500
var position: int = 0

var in_jail: bool = false
var jail_turns: int = 0
var consecutive_doubles: int = 0

var get_out_of_jail_cards: int = 0


func to_snapshot() -> Dictionary:
	return {
		"name": player_name,
		"type": player_type,
		"cash": cash,
		"position": position,
		"in_jail": in_jail,
		"jail_turns": jail_turns,
		"consecutive_doubles": consecutive_doubles,
		"get_out_of_jail_cards": get_out_of_jail_cards,
	}

