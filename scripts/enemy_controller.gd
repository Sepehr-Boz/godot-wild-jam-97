class_name EnemyController
extends Node

enum Enemy { BAT, RAT, SPIDER }
const ENEMY_SOURCE_INDEX: Dictionary[Enemy, int] = {
	Enemy.BAT: 35,
	Enemy.RAT: 38,
	Enemy.SPIDER: 37
}

static var instance: EnemyController
signal enemies_moved(positions: Array[Vector2i])

@onready var _enemies_tilemap = $Enemies
@export var enemy_paths: Dictionary[TileMapPath, Enemy] = {}
@export var enemy_move_outline_color: Color = Color.BLACK
var _enemy_material: ShaderMaterial = preload("res://materials/enemy_tile.tres")
@onready var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _enemy_offsets: Dictionary[TileMapPath, float] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	for path: TileMapPath in enemy_paths.keys():
		path.hide_path()
		_enemy_offsets[path] = _rng.randf()

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
		_enemies_tilemap.set_cell(path.get_current_point(), ENEMY_SOURCE_INDEX[enemy_paths[path]], Vector2i.ZERO)
		var shader: ShaderMaterial = _enemy_material.duplicate()
		shader.set_shader_parameter("offset", _enemy_offsets[path])
		_enemies_tilemap.get_cell_tile_data(path.get_current_point()).material = shader
		_scale_enemy_animation(_enemies_tilemap.get_cell_tile_data(path.get_current_point()))

func kill_enemy_at(coord: Vector2i) -> void:
	for path: TileMapPath in enemy_paths.keys():
		if coord == path.get_current_point():
			path.visible = false
			_enemies_tilemap.erase_cell(coord)
			enemy_paths.erase(path)
			break

func _scale_enemy_animation(tile: TileData) -> void:
	var _animation = func (value: Vector2):
		var shader: ShaderMaterial = tile.material
		shader.set_shader_parameter("scale_addition", value)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(_animation, Vector2.ZERO, Vector2.ONE * 2, 0.1)
	tween.tween_method(_animation, Vector2.ONE * 2, Vector2.ZERO, 0.1)

func _on_character_manager_increment_time() -> void:
	increment_time()
	var positions: Array[Vector2i] = []
	for path: TileMapPath in enemy_paths.keys():
		positions.append(path.get_current_point())
	enemies_moved.emit(positions)
