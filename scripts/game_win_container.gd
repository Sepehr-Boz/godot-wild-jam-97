extends MarginContainer

@onready var _confirm_button: Button = $HBoxContainer/Button
var _level_select_scene: PackedScene = load("res://scenes/level_selection.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_confirm_button.pressed.connect(_on_confirm_press)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = GameManager.instance.all_enemies_dead()

func _on_confirm_press() -> void:
	get_tree().change_scene_to_packed(_level_select_scene)
