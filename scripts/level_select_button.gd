extends Button

@export var level_scene: PackedScene
@export var level_save_name: String
@export var high_score_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(load_level)
	var config: ConfigFile = ConfigFile.new()
	config.load(SaveManager.SAVE_FILE_PATH)
	var level_score: int = config.get_value("Player", level_save_name, -1)
	if level_score != -1:
		high_score_label.text = "High-Score %d" % level_score
	else:
		high_score_label.text = "High-Score N/A"

func load_level() -> void:
	get_tree().change_scene_to_packed(level_scene)
