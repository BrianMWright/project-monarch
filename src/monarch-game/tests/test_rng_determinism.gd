extends RefCounted


func run(ctx) -> void:
	var a := RngService.new(123)
	var b := RngService.new(123)
	for i in range(20):
		ctx.assert_eq(a.roll_d6(), b.roll_d6(), "roll %d matches" % i)

