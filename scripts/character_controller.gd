class_name CharacterController
extends Node2D

# - this class contains 2 tilemaps: one for the character it controls
# and the other for the marker that the character makes
# - this class keeps track of the defined movement the player wants to make
# and then when time is incremented then it moves to that spot

@export var initial_position: Vector2i
# to customise how some characters can move
@export var move_directions: Array[Vector2i] = [
	Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN
]

@export_group("Source IDs")
@export var character_tile_source_id: int
@export var character_number_source_id: int
@export var move_marker_source_id: int
@export var selected_move_marker_source_id: int
@export var attack_marker_source_id: int

@onready var _character_tilemap: TileMapLayer = $Character
@onready var _marker_tilemap: TileMapLayer = $Markers
@onready var _character_material: ShaderMaterial = preload("res://materials/character_tile.tres").duplicate()
var _move_tween: Tween
var _show_tips: bool = false
var _character_selected: bool = false
var character_position: Vector2i
var target_position: Vector2i
var past_movements: Array[Vector2i] = []

var target_positions: Array[Vector2i]:
	get:
		return move_directions.map(func (x: Vector2i): return x + character_position).filter(_target_position_free)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_character_material.set_shader_parameter("offset", GameManager.RNG.randf())
	character_position = initial_position
	target_position = initial_position
	past_movements.append(initial_position)
	clear()
	update()
	
	while not GameManager.instance:
		await get_tree().create_timer(0.1).timeout
	GameManager.instance.increment_time.connect(_on_time_incremented)
	GameManager.instance.decrement_time.connect(_on_time_decremented)
	GameManager.characters.append(self)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		var clicked_cell: Vector2i = _character_tilemap.local_to_map(get_local_mouse_position())
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and clicked_cell == character_position:
			_character_selected = true
			_character_material.set_shader_parameter("remap_outline", true)
		elif event.button_index == MOUSE_BUTTON_LEFT and event.is_released() and _character_selected:
			# if click is outside the movements then ignore
			var destinations: Array = move_directions.map(
				func (x: Vector2i): return character_position + x
			)
			if clicked_cell == character_position:
				target_position = character_position
				for target: Vector2i in target_positions:
					_marker_tilemap.set_cell(target, move_marker_source_id, Vector2.ZERO)
			if clicked_cell in destinations:
				for target: Vector2i in target_positions:
					if clicked_cell == target:
						target_position = clicked_cell
						_marker_tilemap.set_cell(target, selected_move_marker_source_id, Vector2.ZERO)
					else:
						_marker_tilemap.set_cell(target, move_marker_source_id, Vector2.ZERO)
			_character_selected = false
			_character_material.set_shader_parameter("remap_outline", false)
	elif event is InputEventMouse:
		event = event as InputEventMouse
		var hover_coord: Vector2i = _character_tilemap.local_to_map(get_local_mouse_position())
		var used_cells: Array[Vector2i] = _character_tilemap.get_used_cells()
		used_cells.append_array(_marker_tilemap.get_used_cells())
		for coord: Vector2i in used_cells:
			if coord == hover_coord:
				modulate.a = 1.0
				return
		modulate.a = 0.25
	elif event.is_action_pressed("show_tips"):
		_show_tips = true
		show_number()
	elif event.is_action_released("show_tips"):
		_show_tips = false
		_marker_tilemap.erase_cell(character_position)

func _target_position_free(coord: Vector2i) -> bool:
	for character: CharacterController in GameManager.characters:
		if character == self:
			continue
		elif character.character_position == coord:
			return false
		elif character.target_position == coord:
			return false
	return true

func _on_time_incremented(time: int) -> void:
	var should_play_animation: bool
	if time >= len(past_movements):
		# only play the animation if the character moved
		should_play_animation = target_position != character_position
		character_position = target_position
		past_movements.append(character_position)
	elif target_position != past_movements[time]:
		past_movements = past_movements.slice(0, time)
		_on_time_incremented(time)
		return
	else:
		var target: Vector2i = past_movements[time]
		should_play_animation = target != character_position
		character_position = target
		target_position = character_position if time >= len(past_movements) - 1 else past_movements[time + 1]
	clear()
	update()
	if should_play_animation:
		play_move_animation()

func _on_time_decremented(time: int) -> void:
	# only play the animation if the character moved
	var target = past_movements[time]
	var should_play_animation = target != character_position
	character_position = target
	target_position = past_movements[time + 1]
	clear()
	update()
	if should_play_animation:
		play_move_animation()

func clear() -> void:
	_character_tilemap.clear()
	_marker_tilemap.clear()

func update() -> void:
	_character_tilemap.set_cell(character_position, character_tile_source_id, Vector2i.ZERO)
	_character_tilemap.get_cell_tile_data(character_position).material = _character_material
	if _show_tips:
		show_number()
	for target: Vector2i in target_positions:
		if target == target_position:
			_marker_tilemap.set_cell(target, selected_move_marker_source_id, Vector2i.ZERO)
		else:
			_marker_tilemap.set_cell(target, move_marker_source_id, Vector2i.ZERO)

func show_number() -> void:
	_marker_tilemap.set_cell(character_position, character_number_source_id, Vector2i.ZERO)

func play_move_animation() -> void:
	# inner function
	var _move_animation = func (value) -> void:
		_character_material.set_shader_parameter("scale_addition", value)
	
	if _move_tween != null and _move_tween.is_running():
		await _move_tween.finished
	
	_move_tween = get_tree().create_tween()
	_move_tween.tween_method(_move_animation, Vector2.ZERO, Vector2(4, 4), 0.1)
	_move_tween.tween_method(_move_animation, Vector2(4, 4), Vector2.ZERO, 0.1)
