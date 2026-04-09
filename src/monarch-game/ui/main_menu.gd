## main_menu.gd
extends Control

@onready var _button_start: Button = $VBox/Buttons/ButtonStart
@onready var _button_settings: Button = $VBox/Buttons/ButtonSettings
@onready var _button_quit: Button = $VBox/Buttons/ButtonQuit
@onready var _settings_panel = $SettingsPanel


func _ready() -> void:
	_button_start.pressed.connect(_on_start_pressed)
	_button_settings.pressed.connect(_on_settings_pressed)
	_button_quit.pressed.connect(_on_quit_pressed)

	_settings_panel.visible = false
	_settings_panel.closed.connect(_on_settings_closed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _settings_panel.visible:
			_settings_panel.close()
		else:
			_on_quit_pressed()
		get_viewport().set_input_as_handled()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://control.tscn")


func _on_settings_pressed() -> void:
	_settings_panel.open()


func _on_settings_closed() -> void:
	_button_settings.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()
