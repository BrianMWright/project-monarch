## settings.gd
## Lightweight settings store (autoload).
extends Node

signal master_volume_changed(volume_linear: float)

const _CONFIG_PATH := "user://settings.cfg"
const _AUDIO_SECTION := "audio"
const _MASTER_VOLUME_KEY := "master_volume_linear"
const _GAME_SECTION := "game"
const _GAME_MODE_KEY := "mode"
const _FIXED_SEED_ENABLED_KEY := "fixed_seed_enabled"
const _FIXED_SEED_VALUE_KEY := "fixed_seed_value"

var master_volume_linear: float = 1.0

enum GameMode { HOTSEAT, VS_AI }
var game_mode: int = GameMode.VS_AI
var fixed_seed_enabled: bool = false
var fixed_seed_value: int = 12345


func _ready() -> void:
	_load()
	_apply_audio()


func set_master_volume_linear(volume_linear: float) -> void:
	master_volume_linear = clampf(volume_linear, 0.0, 1.0)
	_apply_audio()
	_save()
	master_volume_changed.emit(master_volume_linear)


func set_game_mode(mode: int) -> void:
	game_mode = mode
	_save()


func set_fixed_seed_enabled(enabled: bool) -> void:
	fixed_seed_enabled = enabled
	_save()


func set_fixed_seed_value(value: int) -> void:
	fixed_seed_value = value
	_save()


func _load() -> void:
	var config := ConfigFile.new()
	var err := config.load(_CONFIG_PATH)
	if err != OK:
		master_volume_linear = 1.0
		game_mode = GameMode.VS_AI
		fixed_seed_enabled = false
		fixed_seed_value = 12345
		return
	master_volume_linear = float(config.get_value(_AUDIO_SECTION, _MASTER_VOLUME_KEY, 1.0))
	master_volume_linear = clampf(master_volume_linear, 0.0, 1.0)
	game_mode = int(config.get_value(_GAME_SECTION, _GAME_MODE_KEY, GameMode.VS_AI))
	fixed_seed_enabled = bool(config.get_value(_GAME_SECTION, _FIXED_SEED_ENABLED_KEY, false))
	fixed_seed_value = int(config.get_value(_GAME_SECTION, _FIXED_SEED_VALUE_KEY, 12345))


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value(_AUDIO_SECTION, _MASTER_VOLUME_KEY, master_volume_linear)
	config.set_value(_GAME_SECTION, _GAME_MODE_KEY, game_mode)
	config.set_value(_GAME_SECTION, _FIXED_SEED_ENABLED_KEY, fixed_seed_enabled)
	config.set_value(_GAME_SECTION, _FIXED_SEED_VALUE_KEY, fixed_seed_value)
	config.save(_CONFIG_PATH)


func _apply_audio() -> void:
	var master_bus_index := AudioServer.get_bus_index("Master")
	if master_bus_index == -1:
		return

	var clamped := clampf(master_volume_linear, 0.0, 1.0)
	if clamped <= 0.0001:
		AudioServer.set_bus_mute(master_bus_index, true)
		AudioServer.set_bus_volume_db(master_bus_index, -80.0)
		return

	AudioServer.set_bus_mute(master_bus_index, false)
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(clamped))
