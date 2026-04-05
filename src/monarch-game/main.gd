extends Node2D

func _ready():
	# Wait one frame to ensure everything is loaded
	await get_tree().process_frame
	
	# Find our Player node and tell it to move 2 spaces
	var player = $Player
	player.move_player(2)
