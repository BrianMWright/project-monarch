## main.gd
## Entry point for the Main scene. Wires up core node dependencies and UI.
##
## Orchestration only — no game logic lives here.
## Live Ops note: This is the right place to await a session-start
## remote-config fetch before enabling the Roll button, so tile data
## and dice config are guaranteed fresh from the server before play begins.

extends Control

# UI node references — populated once in _ready(), used by signal callbacks.
var _label_tile: Label
var _label_roll: Label


func _ready() -> void:
	print("[Main] _ready() start")

	# Wait one frame to ensure all child nodes are fully initialised.
	await get_tree().process_frame

	var dice_roller: DiceRoller = $DiceRoller
	var player:      Player     = $Player
	var button_roll: Button     = $ButtonRoll
	_label_tile                 = $LabelTile
	_label_roll                 = $LabelRoll

	print("[Main] nodes found, wiring signals")

	# --- Signal wiring -------------------------------------------------------

	# Core game loop: a roll result drives the player's movement.
	dice_roller.rolled.connect(player.move_player)

	# UI feedback: update the roll display whenever the dice are cast.
	dice_roller.rolled.connect(_on_rolled)

	# UI feedback: update the tile display whenever the player lands.
	player.tile_landed.connect(_on_tile_landed)

	# Player input: pressing the button triggers a roll.
	button_roll.pressed.connect(dice_roller.roll)

	print("[Main] _ready() complete")


# ---------------------------------------------------------------------------
# UI callbacks — keep these thin; they update display only.
# ---------------------------------------------------------------------------

func _on_rolled(steps: int) -> void:
	_label_roll.text = "Roll: %d" % steps


func _on_tile_landed(tile: Dictionary) -> void:
	_label_tile.text = "Tile: %s" % tile.get("name", "—")
