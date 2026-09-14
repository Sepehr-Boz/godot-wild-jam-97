class_name CharacterController
extends Node

# SPECIFICALLY ORDERED THIS WAY BECAUSE ARCHER FOLLOWS MAGE WHICH FOLLOWS TANK
# WHICH FOLLOWS THE KNIGHT
enum Character { KNIGHT, TANK, MAGE, ARCHER }
enum SwitchDirection { FRONT, BACK }
const CHARACTER_SOURCE_INDEX: Dictionary[Character, int] = {
	Character.KNIGHT: 25,
	Character.TANK:23,
	Character.MAGE: 20,
	Character.ARCHER: 34
}
const MOVE_MARKER_SOURCE_INDEX: int = 32
const ONE_MARKER_SOURCE_INDEX: int = 37
const TWO_MARKER_SOURCE_INDEX: int = 38
const THREE_MARKER_SOURCE_INDEX: int = 39
const FOUR_MARKER_SOURCE_INDEX: int = 40

static var instance: CharacterController
signal increment_time()

@export var current_character_outline_color: Color = Color.WHITE
@onready var _character_tilemap: TileMapLayer = $Characters
@onready var _marker_tilemap: TileMapLayer = $Markers
var _character_material: ShaderMaterial = preload("res://materials/character_tile.tres")
var character_positions: Dictionary[Character, Vector2i] = {
	Character.KNIGHT: Vector2i(8, 4),
	Character.TANK: Vector2i(7, 4),
	Character.MAGE: Vector2i(6, 4),
	Character.ARCHER: Vector2i(5, 4)
}
# FRONT = index 0, BACK = last index
var character_queue: Array[Character] = [
	Character.KNIGHT, Character.TANK, Character.MAGE, Character.ARCHER
]
@onready var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _current_character_tween: Tween
var _character_offsets: Dictionary[Character, float] = {}

var current_character: Character:
	get:
		return character_queue[0]
var move_positions: Array[Vector2i]:
	get:
		return _character_tilemap.get_surrounding_cells(character_positions[current_character])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	_character_tilemap.clear()
	_marker_tilemap.clear()
	for type in Character.values():
		_character_offsets[type] = _rng.randf()
		_character_tilemap.set_cell(character_positions[type], CHARACTER_SOURCE_INDEX[type], Vector2i.ZERO)
		var shader: ShaderMaterial = _character_material.duplicate()
		shader.set_shader_parameter("offset", _character_offsets[type])
		_character_tilemap.get_cell_tile_data(character_positions[type]).material = shader
	spawn_move_markers()
	_scale_current_character_animation()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT:
			# check if pressed on any cell surrounding the CURRENT character position
			# and if so then move it and all the companions to that position also
			var clicked_cell: Vector2i = _character_tilemap.local_to_map(_character_tilemap.get_local_mouse_position())
			# DONT ALLOW moving back onto other companions
			for type in Character.values():
				if clicked_cell == character_positions[type]:
					return
			var current_character_position: Vector2i = character_positions[current_character]
			if clicked_cell in move_positions:
				move_characters(clicked_cell - current_character_position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and not event.pressed:
			switch_characters(SwitchDirection.FRONT)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and not event.pressed:
			switch_characters(SwitchDirection.BACK)
	elif event.is_action_pressed("show_tips"):
		spawn_index_markers()
	elif event.is_action_released("show_tips"):
		clear_index_markers()

func move_characters(dir: Vector2i) -> void:
	_character_tilemap.clear()
	clear_move_markers()
	var prev_char_position: Vector2i
	for i in len(character_queue):
		var type: Character = character_queue[i]
		var char_position: Vector2i = character_positions[type]
		if i == 0:
			character_positions[type] += dir
		else:
			character_positions[type] = prev_char_position
		prev_char_position = char_position
		_character_tilemap.set_cell(character_positions[type], CHARACTER_SOURCE_INDEX[type], Vector2i.ZERO)
		var shader: ShaderMaterial = _character_material.duplicate()
		shader.set_shader_parameter("offset", _character_offsets[type])
		_character_tilemap.get_cell_tile_data(character_positions[type]).material = shader
	spawn_move_markers()
	_scale_current_character_animation()
	increment_time.emit()

func switch_characters(direction: SwitchDirection) -> void:
	_character_tilemap.clear()
	clear_move_markers()
	if direction == SwitchDirection.FRONT:
		# move the current character to the back and push everything up
		var character: Character = character_queue.pop_front()
		character_queue.append(character)
		var curr_position: Vector2i = character_positions[character]
		for i in len(character_queue):
			var character_position: Vector2i = character_positions[character_queue[i]]
			character_positions[character_queue[i]] = curr_position
			curr_position = character_position
			_character_tilemap.set_cell(character_positions[character_queue[i]], CHARACTER_SOURCE_INDEX[character_queue[i]], Vector2i.ZERO)
			var shader: ShaderMaterial = _character_material.duplicate()
			shader.set_shader_parameter("offset", _character_offsets[character_queue[i]])
			_character_tilemap.get_cell_tile_data(character_positions[character_queue[i]]).material = shader
	else:
		# push the current character back and the tail to the front
		var character: Character = character_queue.pop_back()
		character_queue.push_front(character)
		var curr_position: Vector2i = character_positions[character]
		for i in range(len(character_queue) - 1, -1, -1):
			var character_position: Vector2i = character_positions[character_queue[i]]
			character_positions[character_queue[i]] = curr_position
			curr_position = character_position
			_character_tilemap.set_cell(character_positions[character_queue[i]], CHARACTER_SOURCE_INDEX[character_queue[i]], Vector2i.ZERO)
			var shader: ShaderMaterial = _character_material.duplicate()
			shader.set_shader_parameter("offset", _character_offsets[character_queue[i]])
			_character_tilemap.get_cell_tile_data(character_positions[character_queue[i]]).material = shader
	spawn_move_markers()
	_scale_current_character_animation()
	increment_time.emit()

func _scale_current_character_animation() -> void:
	var _current_character_animation = func (value: Vector2):
		var shader: ShaderMaterial = _character_tilemap.get_cell_tile_data(character_positions[current_character]).material as ShaderMaterial
		shader.set_shader_parameter("scale_addition", value)
		shader.set_shader_parameter("remap_outline", true)
		shader.set_shader_parameter("remapped_outline_color", current_character_outline_color)
	
	# if another tween is already running then stop it and reset the scale of ALL the characters
	if _current_character_tween != null and _current_character_tween.is_running():
		_current_character_tween.kill()
	for character in Character.values():
		var shader: ShaderMaterial = _character_tilemap.get_cell_tile_data(character_positions[character]).material as ShaderMaterial
		shader.set_shader_parameter("scale_addition", Vector2.ZERO)
		shader.set_shader_parameter("remap_outline", false)
	
	_current_character_tween = get_tree().create_tween()
	_current_character_tween.tween_method(_current_character_animation, Vector2.ZERO, Vector2.ONE * 4, 0.1)
	_current_character_tween.tween_method(_current_character_animation, Vector2.ONE * 4, Vector2.ZERO, 0.1)

func spawn_move_markers() -> void:
	for target_position in move_positions:
		if not intersects_character(target_position):
			_marker_tilemap.set_cell(target_position, MOVE_MARKER_SOURCE_INDEX, Vector2i.ZERO)

func spawn_index_markers() -> void:
	for i in len(character_queue):
		var index: int = i + 1
		var position: Vector2i = character_positions[character_queue[i]]
		match index:
			1: _marker_tilemap.set_cell(position, ONE_MARKER_SOURCE_INDEX, Vector2i.ZERO)
			2: _marker_tilemap.set_cell(position, TWO_MARKER_SOURCE_INDEX, Vector2i.ZERO)
			3: _marker_tilemap.set_cell(position, THREE_MARKER_SOURCE_INDEX, Vector2i.ZERO)
			4: _marker_tilemap.set_cell(position, FOUR_MARKER_SOURCE_INDEX, Vector2i.ZERO)

func clear_move_markers() -> void:
	for position: Vector2i in _marker_tilemap.get_surrounding_cells(character_positions[current_character]):
		if _marker_tilemap.get_cell_source_id(position) == MOVE_MARKER_SOURCE_INDEX:
			_marker_tilemap.erase_cell(position)

func clear_index_markers() -> void:
	for position: Vector2i in character_positions.values():
		_marker_tilemap.erase_cell(position)

func intersects_character(coord: Vector2i) -> bool:
	for type in Character.values():
		if coord == character_positions[type]:
			return true
	return false
