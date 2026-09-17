extends Button

@export var level_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(load_level)

func load_level() -> void:
	get_tree().change_scene_to_packed(level_scene)
