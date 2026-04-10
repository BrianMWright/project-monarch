extends RefCounted


func run(ctx) -> void:
	var ai := AiAgent.new()

	var buy_decision := {"type": "BUY_OR_AUCTION", "price": 200, "cash": 500, "tile_type": "property"}
	ctx.assert_eq(ai.choose_action(buy_decision).get("action"), "buy", "AI buys when cash buffer remains")

	var no_buy := {"type": "BUY_OR_AUCTION", "price": 200, "cash": 350, "tile_type": "property"}
	ctx.assert_eq(ai.choose_action(no_buy).get("action"), "auction", "AI auctions when cash buffer is low")

	var bid := {"type": "AUCTION_BID_OR_PASS", "price": 200, "cash": 500, "current_bid": 190}
	var bid_action := ai.choose_action(bid)
	ctx.assert_eq(bid_action.get("action"), "bid", "AI bids up to cap")
	ctx.assert_eq(int(bid_action.get("amount")), 200, "AI bids expected amount")

	var pass := {"type": "AUCTION_BID_OR_PASS", "price": 200, "cash": 500, "current_bid": 200}
	ctx.assert_eq(ai.choose_action(pass).get("action"), "pass", "AI passes when cap exceeded")

