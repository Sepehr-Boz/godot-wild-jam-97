extends MarginContainer

@export var level_save_name: String
@onready var _confirm_button: Button = $HBoxContainer/Button
var _level_select_scene: PackedScene = load("res://scenes/level_selection.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_confirm_button.pressed.connect(_on_confirm_press)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = GameManager.instance.all_enemies_dead()

func _on_confirm_press() -> void:
	# save the high score first and then move back to the initial scene
	var config: ConfigFile = ConfigFile.new()
	config.load(SaveManager.SAVE_FILE_PATH)
	config.set_value("Player", level_save_name, GameManager.instance.level_clear_time)
	config.save(SaveManager.SAVE_FILE_PATH)
	get_tree().change_scene_to_packed(_level_select_scene)
