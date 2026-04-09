## settings_panel.gd
extends Control

signal closed

@onready var _slider_volume: HSlider = $Panel/VBox/RowVolume/HSliderVolume
@onready var _label_volume_value: Label = $Panel/VBox/RowVolume/LabelVolumeValue
@onready var _button_back: Button = $Panel/VBox/Buttons/ButtonBack


func _ready() -> void:
	_slider_volume.min_value = 0.0
	_slider_volume.max_value = 1.0
	_slider_volume.step = 0.05
	_slider_volume.value = Settings.master_volume_linear
	_update_volume_label(Settings.master_volume_linear)

	_slider_volume.value_changed.connect(_on_volume_changed)
	_button_back.pressed.connect(close)
	Settings.master_volume_changed.connect(_on_master_volume_changed)


func open() -> void:
	visible = true
	_slider_volume.grab_focus()


func close() -> void:
	visible = false
	closed.emit()


func _on_volume_changed(value: float) -> void:
	Settings.set_master_volume_linear(value)
	_update_volume_label(value)


func _on_master_volume_changed(value: float) -> void:
	_slider_volume.value = value
	_update_volume_label(value)


func _update_volume_label(value: float) -> void:
	_label_volume_value.text = "%d%%" % int(round(value * 100.0))

