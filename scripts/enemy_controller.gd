extends Node

enum Enemy { BAT, RAT, SPIDER }
const ENEMY_ATLAS_INDEX: Dictionary[Enemy, Vector2i] = {
	Enemy.BAT: Vector2i(0, 10),
	Enemy.RAT: Vector2i(3, 10),
	Enemy.SPIDER: Vector2i(2, 10)
}

const STEP_TIME: float = 0.5

@onready var _enemies_tilemap = $Enemies
@export var enemy_paths: Dictionary[TileMapPath, Enemy] = {}
var step_timer: float = STEP_TIME

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for path: TileMapPath in enemy_paths.keys():
		path.hide_path()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_tips"):
		for path: TileMapPath in enemy_paths.keys():
			path.show_path()
	elif event.is_action_released("show_tips"):
		for path: TileMapPath in enemy_paths.keys():
			path.hide_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	step_timer -= delta
	if step_timer <= 0.0:
		increment_time()
		step_timer = STEP_TIME

func increment_time() -> void:
	_enemies_tilemap.clear()
	for path: TileMapPath in enemy_paths:
		path.increment_time()
		_enemies_tilemap.set_cell(path.get_current_point(), 0, ENEMY_ATLAS_INDEX[enemy_paths[path]])
