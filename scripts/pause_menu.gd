extends CanvasLayer

@onready var _background: ColorRect = $Background
@onready var _pause_button: Button = $"Pause Button"
@onready var _buttons_container: Control = $VBoxContainer
@onready var _continue_button: Button = $"VBoxContainer/Continue Button"
@onready var _quit_button: Button = $"VBoxContainer/Quit Button"
@onready var _click_audio: AudioStreamPlayer2D = $"Click Audio"
var _level_select_scene: PackedScene = load("res://scenes/level_selection.tscn")
var is_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_pause_button.pressed.connect(
		func ():
			if is_open:
				close_menu()
			else:
				open_menu()
	)
	_continue_button.pressed.connect(close_menu)
	_quit_button.pressed.connect(
		func ():
			_click_audio.play()
			await _click_audio.finished
			get_tree().change_scene_to_packed(_level_select_scene)
	)
	is_open = false
	Engine.time_scale = 1
	_background.visible = false
	_buttons_container.visible = false

func open_menu() -> void:
	_click_audio.play()
	is_open = true
	Engine.time_scale = 0
	_background.visible = true
	_buttons_container.visible = true

func close_menu() -> void:
	_click_audio.play()
	is_open = false
	Engine.time_scale = 1
	_background.visible = false
	_buttons_container.visible = false
