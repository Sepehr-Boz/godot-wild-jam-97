extends Node

enum Enemy { BAT, RAT, SPIDER }
const ENEMY_ATLAS_INDEX: Dictionary[Enemy, Vector2i] = {
	Enemy.BAT: Vector2i(0, 10),
	Enemy.RAT: Vector2i(3, 10),
	Enemy.SPIDER: Vector2i(2, 10)
}

@onready var _enemies_tilemap = $Enemies
@export var enemy_paths: Dictionary[TileMapPath, Enemy] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for path: TileMapPath in enemy_paths.keys():
		path.hide_path()
	CharacterController.instance.increment_time.connect(
		func ():
			increment_time()
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_tips"):
		for path: TileMapPath in enemy_paths.keys():
			path.show_path()
	elif event.is_action_released("show_tips"):
		for path: TileMapPath in enemy_paths.keys():
			path.hide_path()

func increment_time() -> void:
	_enemies_tilemap.clear()
	for path: TileMapPath in enemy_paths:
		path.increment_time()
		_enemies_tilemap.set_cell(path.get_current_point(), 0, ENEMY_ATLAS_INDEX[enemy_paths[path]])
