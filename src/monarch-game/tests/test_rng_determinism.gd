extends RefCounted

const RngService := preload("res://game/rng_service.gd")

func run(ctx) -> void:
	var rng: RngService = RngService.new(123)
	for i in range(100):
		var v: int = rng.roll_d6()
		ctx.assert_true(v >= 1 and v <= 6, "roll %d in [1,6]" % i)
