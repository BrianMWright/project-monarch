## main_menu.gd
extends Control

@onready var _button_start: Button = $VBox/Buttons/ButtonStart
@onready var _button_settings: Button = $VBox/Buttons/ButtonSettings
@onready var _button_quit: Button = $VBox/Buttons/ButtonQuit
@onready var _option_mode: OptionButton = $VBox/Setup/RowMode/OptionMode
@onready var _check_fixed_seed: CheckBox = $VBox/Setup/RowSeed/CheckFixedSeed
@onready var _line_seed: LineEdit = $VBox/Setup/RowSeed/LineEditSeed
@onready var _settings_panel = $SettingsPanel


func _ready() -> void:
	_button_start.pressed.connect(_on_start_pressed)
	_button_settings.pressed.connect(_on_settings_pressed)
	_button_quit.pressed.connect(_on_quit_pressed)

	_option_mode.clear()
	_option_mode.add_item("PvAI (Human vs AI)", Settings.GameMode.VS_AI)
	_option_mode.add_item("Hotseat (2 Humans)", Settings.GameMode.HOTSEAT)
	for i in range(_option_mode.get_item_count()):
		if _option_mode.get_item_id(i) == Settings.game_mode:
			_option_mode.select(i)
			break

	_check_fixed_seed.button_pressed = Settings.fixed_seed_enabled
	_line_seed.text = str(Settings.fixed_seed_value)
	_line_seed.editable = _check_fixed_seed.button_pressed

	_option_mode.item_selected.connect(_on_mode_selected)
	_check_fixed_seed.toggled.connect(_on_fixed_seed_toggled)
	_line_seed.text_submitted.connect(_on_seed_submitted)
	_line_seed.focus_exited.connect(_on_seed_focus_exited)

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


func _on_mode_selected(_index: int) -> void:
	Settings.set_game_mode(_option_mode.get_selected_id())


func _on_fixed_seed_toggled(pressed: bool) -> void:
	_line_seed.editable = pressed
	Settings.set_fixed_seed_enabled(pressed)


func _on_seed_submitted(_text: String) -> void:
	_commit_seed()


func _on_seed_focus_exited() -> void:
	_commit_seed()


func _commit_seed() -> void:
	var seed_value := int(_line_seed.text.strip_edges())
	Settings.set_fixed_seed_value(seed_value)
