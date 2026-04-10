extends RefCounted

const RngService := preload("res://game/rng_service.gd")

func run(ctx) -> void:
	var a: RngService = RngService.new(123)
	var b: RngService = RngService.new(123)
	for i in range(20):
		ctx.assert_eq(a.roll_d6(), b.roll_d6(), "roll %d matches" % i)

