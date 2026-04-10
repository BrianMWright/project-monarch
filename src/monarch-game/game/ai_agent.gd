## ai_agent.gd
## Minimal heuristic AI for v1 decisions (buy/auction/jail/end turn).

class_name AiAgent
extends RefCounted

const SAFETY_BUFFER := 200
const AUCTION_STEP := 10


func choose_action(decision: Dictionary) -> Dictionary:
	var decision_type: String = str(decision.get("type", ""))

	match decision_type:
		"BUY_OR_AUCTION":
			return _buy_or_auction(decision)
		"AUCTION_BID_OR_PASS":
			return _auction_bid_or_pass(decision)
		"JAIL_CHOICE":
			return _jail_choice(decision)
		"END_TURN_CONFIRM":
			return {"action": "end_turn"}
		_:
			return {"action": "pass"}


func _buy_or_auction(decision: Dictionary) -> Dictionary:
	var price := int(decision.get("price", 0))
	var cash := int(decision.get("cash", 0))
	var tile_type := str(decision.get("tile_type", ""))

	var remaining := cash - price
	var should_buy := remaining >= SAFETY_BUFFER
	if tile_type == "railroad" or tile_type == "utility":
		# Slightly more aggressive for these in v1.
		should_buy = remaining >= int(SAFETY_BUFFER * 0.5)

	return {"action": "buy"} if should_buy else {"action": "auction"}


func _auction_bid_or_pass(decision: Dictionary) -> Dictionary:
	var price := int(decision.get("price", 0))
	var cash := int(decision.get("cash", 0))
	var current_bid := int(decision.get("current_bid", 0))

	var cap := min(price, cash - SAFETY_BUFFER)
	var next_bid := current_bid + AUCTION_STEP
	if cap >= next_bid:
		return {"action": "bid", "amount": next_bid}
	return {"action": "pass"}


func _jail_choice(decision: Dictionary) -> Dictionary:
	var cash := int(decision.get("cash", 0))
	var cards := int(decision.get("get_out_cards", 0))
	var jail_turns := int(decision.get("jail_turns", 0))

	if cards > 0 and cash < 150:
		return {"action": "use_card"}

	if cash > 200 or jail_turns >= 2:
		return {"action": "pay_fine"}

	return {"action": "roll"}

