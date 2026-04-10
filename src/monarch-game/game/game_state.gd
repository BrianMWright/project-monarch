## game_state.gd
## Authoritative rules engine for a classic-like Monopoly loop (v1).
## Supports 2 players: P1 human, P2 AI (or hotseat).

class_name GameState
extends RefCounted

const BoardData := preload("res://BoardData.gd")
const RngService := preload("res://game/rng_service.gd")
const Deck := preload("res://game/deck.gd")
const PlayerState := preload("res://game/player_state.gd")

signal state_changed(snapshot: Dictionary)
signal decision_requested(decision: Dictionary)
signal log_line(message: String)
signal game_over(winner_index: int)

const GO_MONEY := 200
const JAIL_FINE := 50

enum Phase {
	NOT_STARTED,
	AWAIT_ROLL,
	AWAIT_DECISION,
	GAME_OVER,
}

var phase: int = Phase.NOT_STARTED

var board_data: BoardData = BoardData.new()
var rng: RngService
var chance_deck: Deck = Deck.new()
var chest_deck: Deck = Deck.new()

var players: Array = []
var current_player_index: int = 0

var owners: Dictionary = {} # tile_index -> player_index

var last_roll: Array[int] = [0, 0]
var _pending_decision: Dictionary = {}
var _auction_state: Dictionary = {}

var seed: int = 0


func setup(vs_ai: bool, fixed_seed_enabled: bool, fixed_seed_value: int) -> void:
	players = []

	var p1: PlayerState = PlayerState.new()
	p1.player_name = "Player 1"
	p1.player_type = PlayerState.PlayerType.HUMAN
	players.append(p1)

	var p2: PlayerState = PlayerState.new()
	p2.player_name = "Player 2"
	p2.player_type = PlayerState.PlayerType.AI if vs_ai else PlayerState.PlayerType.HUMAN
	players.append(p2)

	seed = fixed_seed_value if fixed_seed_enabled else int(Time.get_unix_time_from_system())
	rng = RngService.new(seed)

	owners = {}
	last_roll = [0, 0]
	current_player_index = 0
	_pending_decision = {}
	_auction_state = {}

	_reset_decks()
	phase = Phase.AWAIT_ROLL

	_emit_log("Seed: %d" % seed)
	_emit_log("Game start: %s vs %s" % [
		players[0].player_name,
		("AI" if players[1].player_type == PlayerState.PlayerType.AI else "Human"),
	])

	_emit_state()


func get_snapshot() -> Dictionary:
	var player_snaps: Array[Dictionary] = []
	for p in players:
		player_snaps.append(p.to_snapshot())

	return {
		"phase": phase,
		"seed": seed,
		"current_player_index": current_player_index,
		"players": player_snaps,
		"owners": owners.duplicate(),
		"last_roll": last_roll.duplicate(),
		"pending_decision": _pending_decision.duplicate(),
		"auction": _auction_state.duplicate(),
	}


func request_roll() -> void:
	if phase != Phase.AWAIT_ROLL:
		return

	var player: PlayerState = _current_player()
	if player.in_jail:
		_request_jail_choice(player)
		return

	_roll_and_move(player)


func respond(action: Dictionary) -> void:
	if phase != Phase.AWAIT_DECISION:
		return
	if _pending_decision.is_empty():
		return

	var decision_type: String = str(_pending_decision.get("type", ""))
	match decision_type:
		"BUY_OR_AUCTION":
			_handle_buy_or_auction(action)
		"AUCTION_BID_OR_PASS":
			_handle_auction_bid_or_pass(action)
		"JAIL_CHOICE":
			_handle_jail_choice(action)
		"END_TURN_CONFIRM":
			_end_turn()
		_:
			_end_turn()


func _current_player() -> PlayerState:
	return players[current_player_index]


func _emit_state() -> void:
	state_changed.emit(get_snapshot())


func _emit_log(message: String) -> void:
	print("[Game] %s" % message)
	log_line.emit(message)


func _reset_decks() -> void:
	chance_deck.reset([
		{"type": "move", "position": 0, "text": "Advance to Go (Collect $200)."},
		{"type": "money", "amount": 50, "text": "Bank pays you dividend of $50."},
		{"type": "money", "amount": -15, "text": "Pay poor tax of $15."},
		{"type": "jail", "text": "Go to Jail. Do not pass Go. Do not collect $200."},
	], rng)

	chest_deck.reset([
		{"type": "money", "amount": 200, "text": "Inheritance: Collect $200."},
		{"type": "money", "amount": -50, "text": "Doctor's fees: Pay $50."},
		{"type": "card", "card": "get_out_of_jail", "text": "Get Out of Jail Free."},
		{"type": "move", "position": 0, "text": "Advance to Go (Collect $200)."},
	], rng)


func _roll_and_move(player: PlayerState) -> void:
	var d1: int = rng.roll_d6()
	var d2: int = rng.roll_d6()
	last_roll = [d1, d2]

	var is_doubles: bool = d1 == d2
	player.consecutive_doubles = (player.consecutive_doubles + 1) if is_doubles else 0

	_emit_log("%s rolled %d + %d%s" % [
		player.player_name,
		d1,
		d2,
		(" (doubles)" if is_doubles else ""),
	])

	if player.consecutive_doubles >= 3:
		_send_to_jail(player, "Rolled doubles three times.")
		_finish_turn()
		return

	var steps: int = d1 + d2
	_move_player_steps(player, steps)
	_resolve_landing(player)

	if phase == Phase.GAME_OVER:
		return

	if player.in_jail:
		_finish_turn()
		return

	if is_doubles:
		_emit_log("%s gets another roll (doubles)." % player.player_name)
		phase = Phase.AWAIT_ROLL
		_emit_state()
		return

	_finish_turn()


func _move_player_steps(player: PlayerState, steps: int) -> void:
	var old_pos: int = player.position
	player.position = (player.position + steps) % board_data.get_tile_count()
	if player.position < old_pos:
		player.cash += GO_MONEY
		_emit_log("%s passed Go (+$%d)." % [player.player_name, GO_MONEY])


func _resolve_landing(player: PlayerState) -> void:
	var tile: Dictionary = board_data.get_tile(player.position)
	_emit_log("%s landed on %s." % [player.player_name, str(tile.get("name", "Unknown"))])

	var tile_type: String = str(tile.get("type", ""))
	match tile_type:
		"go", "free_parking", "jail":
			pass
		"go_to_jail":
			_send_to_jail(player, "Go To Jail.")
		"tax":
			_apply_money(player, -int(tile.get("tax", 0)), "Tax")
		"chance":
			_apply_card(player, chance_deck.draw())
		"chest":
			_apply_card(player, chest_deck.draw())
		"property", "railroad", "utility":
			_handle_purchasable_tile(player, tile)
		_:
			pass

	_emit_state()


func _apply_card(player: PlayerState, card: Dictionary) -> void:
	if card.is_empty():
		return

	_emit_log("Card: %s" % str(card.get("text", "Unknown card.")))
	var card_type := str(card.get("type", ""))
	match card_type:
		"money":
			_apply_money(player, int(card.get("amount", 0)), "Card")
		"move":
			_move_to(player, int(card.get("position", 0)), true)
			_resolve_landing(player)
		"jail":
			_send_to_jail(player, "Card effect.")
		"card":
			if str(card.get("card", "")) == "get_out_of_jail":
				player.get_out_of_jail_cards += 1
				_emit_log("%s received a Get Out of Jail Free card." % player.player_name)


func _move_to(player: PlayerState, position: int, collect_go: bool) -> void:
	var old_pos: int = player.position
	player.position = position % board_data.get_tile_count()
	if collect_go and player.position < old_pos:
		player.cash += GO_MONEY
		_emit_log("%s passed Go (+$%d)." % [player.player_name, GO_MONEY])


func _send_to_jail(player: PlayerState, reason: String) -> void:
	_emit_log("%s goes to Jail. (%s)" % [player.player_name, reason])
	player.in_jail = true
	player.jail_turns = 0
	player.consecutive_doubles = 0
	_move_to(player, board_data.get_jail_index(), false)


func _apply_money(player: PlayerState, delta: int, reason: String) -> void:
	if delta == 0:
		return
	player.cash += delta
	if delta > 0:
		_emit_log("%s receives $%d (%s)." % [player.player_name, delta, reason])
	else:
		_emit_log("%s pays $%d (%s)." % [player.player_name, abs(delta), reason])


func _handle_purchasable_tile(player: PlayerState, tile: Dictionary) -> void:
	var tile_index := int(tile.get("index", player.position))
	var owner := owners.get(tile_index, -1)

	if owner == -1:
		_request_buy_or_auction(tile, player)
		return

	if int(owner) == current_player_index:
		return

	var rent := _calculate_rent(tile_index, tile)
	_emit_log("%s owes rent: $%d." % [player.player_name, rent])

	players[int(owner)].cash += rent
	player.cash -= rent
	_check_bankruptcy(player)


func _request_buy_or_auction(tile: Dictionary, player: PlayerState) -> void:
	var tile_index := int(tile.get("index", player.position))
	var price := int(tile.get("price", 0))

	_pending_decision = {
		"type": "BUY_OR_AUCTION",
		"tile_index": tile_index,
		"tile_name": str(tile.get("name", "")),
		"tile_type": str(tile.get("type", "")),
		"price": price,
		"cash": player.cash,
	}
	phase = Phase.AWAIT_DECISION
	decision_requested.emit(_pending_decision.duplicate())


func _handle_buy_or_auction(action: Dictionary) -> void:
	var player: PlayerState = _current_player()
	var act: String = str(action.get("action", ""))
	var tile_index: int = int(_pending_decision.get("tile_index", player.position))
	var tile: Dictionary = board_data.get_tile(tile_index)
	var price := int(tile.get("price", 0))

	_pending_decision = {}

	if act == "buy":
		if player.cash >= price and price > 0:
			player.cash -= price
			owners[tile_index] = current_player_index
			_emit_log("%s bought %s for $%d." % [player.player_name, str(tile.get("name", "")), price])
		else:
			_emit_log("%s cannot afford %s, starting auction." % [player.player_name, str(tile.get("name", ""))])
			_begin_auction(tile_index)
			return
	elif act == "auction":
		_begin_auction(tile_index)
		return

	_finish_turn()


func _begin_auction(tile_index: int) -> void:
	var tile: Dictionary = board_data.get_tile(tile_index)
	_emit_log("Auction begins for %s." % str(tile.get("name", "")))

	_auction_state = {
		"tile_index": tile_index,
		"current_bid": 0,
		"high_bidder": -1,
		"passes_in_row": 0,
		"bidder_index": (current_player_index + 1) % players.size(),
	}

	_request_auction_action()


func _request_auction_action() -> void:
	var tile_index := int(_auction_state.get("tile_index", 0))
	var tile: Dictionary = board_data.get_tile(tile_index)
	var bidder_index: int = int(_auction_state.get("bidder_index", 0))
	var bidder: PlayerState = players[bidder_index]

	_pending_decision = {
		"type": "AUCTION_BID_OR_PASS",
		"tile_index": tile_index,
		"tile_name": str(tile.get("name", "")),
		"tile_type": str(tile.get("type", "")),
		"price": int(tile.get("price", 0)),
		"current_bid": int(_auction_state.get("current_bid", 0)),
		"min_step": 10,
		"cash": bidder.cash,
		"bidder_index": bidder_index,
	}
	phase = Phase.AWAIT_DECISION
	decision_requested.emit(_pending_decision.duplicate())


func _handle_auction_bid_or_pass(action: Dictionary) -> void:
	var act := str(action.get("action", ""))
	var bidder_index := int(_pending_decision.get("bidder_index", 0))
	var tile_index := int(_pending_decision.get("tile_index", 0))

	var current_bid := int(_auction_state.get("current_bid", 0))
	var next_bid := current_bid + 10

	if act == "bid":
		var bid_amount := int(action.get("amount", next_bid))
		if bid_amount < next_bid:
			bid_amount = next_bid
		if players[bidder_index].cash < bid_amount:
			act = "pass"
		else:
			_auction_state["current_bid"] = bid_amount
			_auction_state["high_bidder"] = bidder_index
			_auction_state["passes_in_row"] = 0
			_emit_log("%s bids $%d." % [players[bidder_index].player_name, bid_amount])

	if act == "pass":
		_auction_state["passes_in_row"] = int(_auction_state.get("passes_in_row", 0)) + 1
		_emit_log("%s passes." % players[bidder_index].player_name)

	_pending_decision = {}

	_auction_state["bidder_index"] = (bidder_index + 1) % players.size()

	var high_bidder := int(_auction_state.get("high_bidder", -1))
	var passes := int(_auction_state.get("passes_in_row", 0))

	if passes >= players.size():
		if high_bidder == -1:
			_emit_log("Auction ended with no bids.")
		else:
			var final_bid := int(_auction_state.get("current_bid", 0))
			players[high_bidder].cash -= final_bid
			owners[tile_index] = high_bidder
			_emit_log("%s won the auction for $%d." % [players[high_bidder].player_name, final_bid])
			_check_bankruptcy(players[high_bidder])

		_auction_state = {}
		_finish_turn()
		return

	_request_auction_action()


func _request_jail_choice(player: PlayerState) -> void:
	_pending_decision = {
		"type": "JAIL_CHOICE",
		"cash": player.cash,
		"jail_turns": player.jail_turns,
		"get_out_cards": player.get_out_of_jail_cards,
	}
	phase = Phase.AWAIT_DECISION
	decision_requested.emit(_pending_decision.duplicate())


func _handle_jail_choice(action: Dictionary) -> void:
	var player: PlayerState = _current_player()
	var act := str(action.get("action", ""))
	_pending_decision = {}

	match act:
		"use_card":
			if player.get_out_of_jail_cards > 0:
				player.get_out_of_jail_cards -= 1
				player.in_jail = false
				player.jail_turns = 0
				_emit_log("%s used a Get Out of Jail Free card." % player.player_name)
				phase = Phase.AWAIT_ROLL
				_emit_state()
				return
		"pay_fine":
			if player.cash >= JAIL_FINE:
				player.cash -= JAIL_FINE
				player.in_jail = false
				player.jail_turns = 0
				_emit_log("%s paid $%d to get out of jail." % [player.player_name, JAIL_FINE])
				phase = Phase.AWAIT_ROLL
				_emit_state()
				return
		"roll":
			_handle_jail_roll(player)
			return
		_:
			_handle_jail_roll(player)
			return

	_handle_jail_roll(player)


func _handle_jail_roll(player: PlayerState) -> void:
	var d1: int = rng.roll_d6()
	var d2: int = rng.roll_d6()
	last_roll = [d1, d2]
	var is_doubles: bool = d1 == d2

	_emit_log("%s rolls in jail: %d + %d%s" % [
		player.player_name,
		d1,
		d2,
		(" (doubles)" if is_doubles else ""),
	])

	if is_doubles:
		player.in_jail = false
		player.jail_turns = 0
		player.consecutive_doubles = 0
		_emit_log("%s rolled doubles and leaves jail." % player.player_name)
		_move_player_steps(player, d1 + d2)
		_resolve_landing(player)
		_finish_turn()
		return

	player.jail_turns += 1
	if player.jail_turns >= 3:
		if player.cash >= JAIL_FINE:
			player.cash -= JAIL_FINE
		player.in_jail = false
		player.jail_turns = 0
		_emit_log("%s served 3 turns; pays $%d and moves." % [player.player_name, JAIL_FINE])
		_move_player_steps(player, d1 + d2)
		_resolve_landing(player)

	_finish_turn()


func _calculate_rent(tile_index: int, tile: Dictionary) -> int:
	var tile_type := str(tile.get("type", ""))
	match tile_type:
		"railroad":
			return _railroad_rent(tile_index)
		"utility":
			return _utility_rent(tile_index)
		"property":
			var base_rent := int(tile.get("base_rent", 0))
			if _owns_monopoly(int(owners.get(tile_index, -1)), str(tile.get("group", ""))):
				return base_rent * 2
			return base_rent
		_:
			return 0


func _railroad_rent(tile_index: int) -> int:
	var owner := int(owners.get(tile_index, -1))
	if owner < 0:
		return 0
	var count := 0
	for idx in board_data.get_railroad_indices():
		if int(owners.get(idx, -1)) == owner:
			count += 1
	match count:
		1:
			return 25
		2:
			return 50
		3:
			return 100
		_:
			return 200


func _utility_rent(tile_index: int) -> int:
	var owner := int(owners.get(tile_index, -1))
	if owner < 0:
		return 0
	var count := 0
	for idx in board_data.get_utility_indices():
		if int(owners.get(idx, -1)) == owner:
			count += 1
	var multiplier := 4 if count <= 1 else 10
	return (last_roll[0] + last_roll[1]) * multiplier


func _owns_monopoly(owner_index: int, group: String) -> bool:
	if owner_index < 0 or group.is_empty():
		return false
	var indices := board_data.get_property_group_indices(group)
	if indices.is_empty():
		return false
	for idx in indices:
		if int(owners.get(idx, -1)) != owner_index:
			return false
	return true


func _finish_turn() -> void:
	if phase == Phase.GAME_OVER:
		return

	_pending_decision = {"type": "END_TURN_CONFIRM"}
	phase = Phase.AWAIT_DECISION
	decision_requested.emit(_pending_decision.duplicate())
	_emit_state()


func _end_turn() -> void:
	_pending_decision = {}

	current_player_index = (current_player_index + 1) % players.size()
	phase = Phase.AWAIT_ROLL
	_emit_log("Turn: %s" % _current_player().player_name)
	_emit_state()


func _check_bankruptcy(player: PlayerState) -> void:
	if player.cash >= 0:
		return

	var loser_index := players.find(player)
	if loser_index == -1:
		loser_index = current_player_index
	var winner_index := 1 - loser_index

	phase = Phase.GAME_OVER
	_emit_log("%s is bankrupt. Game over." % player.player_name)
	game_over.emit(winner_index)
	_emit_state()

