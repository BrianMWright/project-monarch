## main.gd
## Entry point for the Main scene. Wires up core node dependencies and UI.
##
## Orchestration only — no game logic lives here.
## Live Ops note: This is the right place to await a session-start
## remote-config fetch before enabling the Roll button, so tile data
## and dice config are guaranteed fresh from the server before play begins.

extends Node2D

# UI node references — populated once in _ready(), used by signal callbacks.
var _label_tile: Label
var _label_roll: Label


func _ready() -> void:
	# Wait one frame to ensure all child nodes are fully initialised.
	await get_tree().process_frame

	var dice_roller: DiceRoller = $DiceRoller
	var player:      Player     = $Player
	var button_roll: Button     = $UI/ButtonRoll
	_label_tile                 = $UI/LabelTile
	_label_roll                 = $UI/LabelRoll

	# --- Signal wiring -------------------------------------------------------

	# Core game loop: a roll result drives the player's movement.
	dice_roller.rolled.connect(player.move_player)

	# UI feedback: update the roll display whenever the dice are cast.
	# Live Ops note: also connect dice_roller.rolled to an analytics event here.
	dice_roller.rolled.connect(_on_rolled)

	# UI feedback: update the tile display whenever the player lands.
	# Live Ops note: connect player.tile_landed to a tile-event handler here
	# (e.g. trigger a "Community Chest" card draw from a remote deck).
	player.tile_landed.connect(_on_tile_landed)

	# Player input: pressing the button triggers a roll.
	# The hardcoded dice_roller.roll() call that was in _ready() is gone —
	# the player now owns when their turn starts.
	button_roll.pressed.connect(dice_roller.roll)


# ---------------------------------------------------------------------------
# UI callbacks — keep these thin; they update display only.
# ---------------------------------------------------------------------------

func _on_rolled(steps: int) -> void:
	_label_roll.text = "Roll: %d" % steps


func _on_tile_landed(tile: Dictionary) -> void:
	_label_tile.text = "Tile: %s" % tile.get("name", "—")
