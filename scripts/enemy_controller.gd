class_name EnemyController
extends Node2D

# - this class contains 2 tilemaps: one for the enemy it controls
# and the other for the path that it follows
# - this class moves the enemy along the path and then can either move to
# the end and stop (NONE), turn around and move back to the start
# repeatedly (TURN_AROUND), or keep looping for when the paths are
# closed (LOOP)
# - the path jump defines how quickly the enemy moves through the path,
# 1 means it will move from point to next, 2 = it will skip 1, 3 will skip 2 etc.

enum LoopType { NONE, TURN_AROUND, LOOP }

@export var enemy_tile_source_id: int
@export var path_points: Array[Vector2i] = []
@export var path_jump: int = 1
@export var path_loop: LoopType = LoopType.TURN_AROUND
@export var start_at_random_point: bool = false

@onready var _enemy_tilemap: TileMapLayer = $Enemy
@onready var _path_tilemap: TileMapLayer = $Path
@onready var _enemy_material: ShaderMaterial = preload("res://materials/enemy_tile.tres").duplicate()
var _move_tween: Tween
var _show_tips: bool = false
var _killed_at_time: int = INT64_MAX
var enemy_position: Vector2i
var path_offset: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_enemy_material.set_shader_parameter("offset", GameManager.RNG.randf())
	path_offset = 0 if not start_at_random_point else GameManager.RNG.randi_range(0, len(path_points) - 1)
	enemy_position = path_points[path_offset]
	_path_tilemap.modulate.a = 0.25
	clear()
	update()
	
	while not GameManager.instance:
		await get_tree().create_timer(0.1).timeout
	GameManager.instance.increment_time.connect(_on_time_incremented)
	GameManager.instance.decrement_time.connect(_on_time_decremented)
	GameManager.instance.enemy_killed_at.connect(_on_enemy_killed_at)
	GameManager.enemies.append(self)

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		event = event as InputEventMouse
		var hover_coord: Vector2i = _enemy_tilemap.local_to_map(get_local_mouse_position())
		var used_cells: Array[Vector2i] = _enemy_tilemap.get_used_cells()
		used_cells.append_array(_path_tilemap.get_used_cells())
		if hover_coord in used_cells and _path_tilemap.modulate.a == 0.25:
			_show_tips = true
			_path_tilemap.modulate.a = 1.0
		elif hover_coord not in used_cells and _path_tilemap.modulate.a == 1.0:
			_show_tips = false
			_path_tilemap.modulate.a = 0.25

func _on_time_incremented(time: int) -> void:
	enemy_position = sample_path(path_offset + time * path_jump)
	clear()
	if time >= _killed_at_time:
		return
	else:
		_killed_at_time = INT64_MAX
	update()
	play_move_animation()

func _on_time_decremented(time: int) -> void:
	enemy_position = sample_path(path_offset + time * path_jump)
	clear()
	if time >= _killed_at_time:
		return
	else:
		_killed_at_time = INT64_MAX
	update()
	play_move_animation()

func _on_enemy_killed_at(coord: Vector2i, time: int) -> void:
	if enemy_position == coord:
		_killed_at_time = time
		_enemy_tilemap.clear()
		_path_tilemap.modulate.a = 0.0

func sample_path(index: int) -> Vector2i:
	if path_loop == LoopType.NONE:
		return path_points[clampi(index, 0, len(path_points) - 1)]
	elif path_loop == LoopType.TURN_AROUND:
		var num_loops_completed: int = index / len(path_points)
		if num_loops_completed % 2 == 0:
			return path_points[index % len(path_points)]
		else:
			return path_points[len(path_points) - 1 - index % len(path_points)]
	else:
		return path_points[index % len(path_points)]

func clear() -> void:
	_enemy_tilemap.clear()

func update() -> void:
	_enemy_tilemap.set_cell(enemy_position, enemy_tile_source_id, Vector2i.ZERO)
	_enemy_tilemap.get_cell_tile_data(enemy_position).material = _enemy_material
	_path_tilemap.modulate.a = 1.0 if _show_tips else 0.25

func play_move_animation() -> void:
	var _move_animation = func (value) -> void:
		_enemy_material.set_shader_parameter("scale_addition", value)
	
	if _move_tween != null and _move_tween.is_running():
		await _move_tween.finished
	
	_move_tween = get_tree().create_tween()
	_move_tween.tween_method(_move_animation, Vector2.ZERO, Vector2(2, 2), 0.1)
	_move_tween.tween_method(_move_animation, Vector2(2, 2), Vector2.ZERO, 0.1)
