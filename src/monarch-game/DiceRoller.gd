## DiceRoller.gd
## A self-contained utility node that simulates a standard Monopoly dice roll.
##
## Usage:
##   1. Add as a child node in your scene.
##   2. Connect the [signal rolled] signal to [method Player.move_player].
##   3. Call [method roll] whenever the player should take their turn.
##
## Live Ops note: [member num_dice] and [member die_faces] are exported so a
## remote-config system can override them at runtime for limited-time events
## (e.g. "Speed Week" with 3 dice, or a d8 variant) without an app-store update.

class_name DiceRoller
extends Node

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted after every roll with the total number of steps to move.
## Connect this directly to [method Player.move_player].
signal rolled(steps: int)

# ---------------------------------------------------------------------------
# Configuration — overridable via Live Ops / remote config
# ---------------------------------------------------------------------------

## Number of dice to roll. Standard Monopoly uses 2.
@export var num_dice: int = 2

## Number of faces on each die. Standard is 6.
@export var die_faces: int = 6

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Rolls all dice, prints each result, emits [signal rolled] with the total,
## and returns the total for callers that want a synchronous result.
##
## Live Ops note: Insert a pre-roll modifier hook here to apply buffs such as
## "guaranteed doubles" or "minimum roll 6" from a server-side event config.
func roll() -> int:
	var results: Array[int] = []
	var total: int = 0

	for i in num_dice:
		var result: int = randi_range(1, die_faces)
		results.append(result)
		total += result

	print("[DiceRoller] Rolled %s → total: %d" % [str(results), total])
	rolled.emit(total)
	return total
