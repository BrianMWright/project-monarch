## pause_menu.gd
extends CanvasLayer

signal resume_requested
signal main_menu_requested
signal quit_requested

@onready var _button_resume: Button = $Overlay/Panel/VBox/Buttons/ButtonResume
@onready var _button_settings: Button = $Overlay/Panel/VBox/Buttons/ButtonSettings
@onready var _button_main_menu: Button = $Overlay/Panel/VBox/Buttons/ButtonMainMenu
@onready var _button_quit: Button = $Overlay/Panel/VBox/Buttons/ButtonQuit
@onready var _settings_panel = $SettingsPanel


func _ready() -> void:
	visible = false
	_settings_panel.visible = false
	_settings_panel.closed.connect(_on_settings_closed)

	_button_resume.pressed.connect(_on_resume_pressed)
	_button_settings.pressed.connect(_on_settings_pressed)
	_button_main_menu.pressed.connect(_on_main_menu_pressed)
	_button_quit.pressed.connect(_on_quit_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		if _settings_panel.visible:
			_settings_panel.close()
		else:
			_on_resume_pressed()
		get_viewport().set_input_as_handled()


func open() -> void:
	visible = true
	_button_resume.grab_focus()


func close() -> void:
	_settings_panel.visible = false
	visible = false


func _on_resume_pressed() -> void:
	close()
	resume_requested.emit()


func _on_settings_pressed() -> void:
	_settings_panel.open()


func _on_settings_closed() -> void:
	_button_settings.grab_focus()


func _on_main_menu_pressed() -> void:
	close()
	main_menu_requested.emit()


func _on_quit_pressed() -> void:
	close()
	quit_requested.emit()
