extends RefCounted

const RngService := preload("res://game/rng_service.gd")

func run(ctx) -> void:
	var rng: RngService = RngService.new(123)
	var first_pass: Array[int] = []
	for _i in range(20):
		first_pass.append(rng.roll_d6())

	rng.reseed(123)
	for i in range(20):
		ctx.assert_eq(rng.roll_d6(), first_pass[i], "roll %d matches" % i)
