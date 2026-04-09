## settings.gd
## Lightweight settings store (autoload).
extends Node

signal master_volume_changed(volume_linear: float)

const _CONFIG_PATH := "user://settings.cfg"
const _AUDIO_SECTION := "audio"
const _MASTER_VOLUME_KEY := "master_volume_linear"

var master_volume_linear: float = 1.0


func _ready() -> void:
	_load()
	_apply_audio()


func set_master_volume_linear(volume_linear: float) -> void:
	master_volume_linear = clampf(volume_linear, 0.0, 1.0)
	_apply_audio()
	_save()
	master_volume_changed.emit(master_volume_linear)


func _load() -> void:
	var config := ConfigFile.new()
	var err := config.load(_CONFIG_PATH)
	if err != OK:
		master_volume_linear = 1.0
		return
	master_volume_linear = float(config.get_value(_AUDIO_SECTION, _MASTER_VOLUME_KEY, 1.0))
	master_volume_linear = clampf(master_volume_linear, 0.0, 1.0)


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value(_AUDIO_SECTION, _MASTER_VOLUME_KEY, master_volume_linear)
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

