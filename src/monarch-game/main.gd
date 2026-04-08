## main.gd — diagnostic build, bypasses Control layout entirely
extends Node2D

func _ready() -> void:
	# Change the clear color from black to green — proves GDScript executed.
	# If the screen turns green, GDScript runs but drawing may still be broken.
	RenderingServer.set_default_clear_color(Color(0.0, 0.5, 0.0, 1.0))


func _draw() -> void:
	# Draw a bright red filled rectangle covering most of the screen.
	# Uses low-level CanvasItem drawing — no Control/Layout system involved.
	draw_rect(Rect2(50, 100, 900, 1800), Color(1.0, 0.0, 0.0, 1.0))

	# Draw "DRAW OK" in white — confirms font rendering works.
	var font := ThemeDB.fallback_font
	if font:
		draw_string(font, Vector2(100, 600), "DRAW OK", HORIZONTAL_ALIGNMENT_LEFT,
				-1, 120, Color(1, 1, 1, 1))
