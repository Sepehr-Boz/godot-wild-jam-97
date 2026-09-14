class_name CharacterController
extends Node

# SPECIFICALLY ORDERED THIS WAY BECAUSE ARCHER FOLLOWS MAGE WHICH FOLLOWS TANK
# WHICH FOLLOWS THE KNIGHT
enum Character { KNIGHT, TANK, MAGE, ARCHER }
enum SwitchDirection { FRONT, BACK }
const CHARACTER_ATLAS_INDEX: Dictionary[Character, Vector2i] = {
	Character.KNIGHT: Vector2i(0, 8),
	Character.TANK: Vector2i(3, 7),
	Character.MAGE: Vector2i(0, 7),
	Character.ARCHER: Vector2i(4, 9)
}
const MOVE_MARKER_ATLAS_INDEX: Vector2i = Vector2i(7, 3)
const ONE_MARKER_ATLAS_INDEX: Vector2i = Vector2i(1, 10)
const TWO_MARKER_ATLAS_INDEX: Vector2i = Vector2i(2, 10)
const THREE_MARKER_ATLAS_INDEX: Vector2i = Vector2i(3, 10)
const FOUR_MARKER_ATLAS_INDEX: Vector2i = Vector2i(4, 10)

static var instance: CharacterController
signal increment_time()

@export var current_character_outline_color: Color = Color.WHITE
@onready var _character_tilemap: TileMapLayer = $Characters
@onready var _marker_tilemap: TileMapLayer = $Markers
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
var _current_character_tween: Tween

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
		_character_tilemap.set_cell(character_positions[type], 0, CHARACTER_ATLAS_INDEX[type])
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
		_character_tilemap.set_cell(character_positions[type], 0, CHARACTER_ATLAS_INDEX[type])
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
			_character_tilemap.set_cell(character_positions[character_queue[i]], 0, CHARACTER_ATLAS_INDEX[character_queue[i]])
	else:
		# push the current character back and the tail to the front
		var character: Character = character_queue.pop_back()
		character_queue.push_front(character)
		var curr_position: Vector2i = character_positions[character]
		for i in range(len(character_queue) - 1, -1, -1):
			var character_position: Vector2i = character_positions[character_queue[i]]
			character_positions[character_queue[i]] = curr_position
			curr_position = character_position
			_character_tilemap.set_cell(character_positions[character_queue[i]], 0, CHARACTER_ATLAS_INDEX[character_queue[i]])
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
	_current_character_tween.tween_method(_current_character_animation, Vector2.ZERO, Vector2(96, 96), 0.1)
	_current_character_tween.tween_method(_current_character_animation, Vector2(96, 96), Vector2.ZERO, 0.1)

func spawn_move_markers() -> void:
	for target_position in move_positions:
		if not intersects_character(target_position):
			_marker_tilemap.set_cell(target_position, 0, MOVE_MARKER_ATLAS_INDEX)

func spawn_index_markers() -> void:
	for i in len(character_queue):
		var index: int = i + 1
		var position: Vector2i = character_positions[character_queue[i]]
		match index:
			1: _marker_tilemap.set_cell(position, 0, ONE_MARKER_ATLAS_INDEX)
			2: _marker_tilemap.set_cell(position, 0, TWO_MARKER_ATLAS_INDEX)
			3: _marker_tilemap.set_cell(position, 0, THREE_MARKER_ATLAS_INDEX)
			4: _marker_tilemap.set_cell(position, 0, FOUR_MARKER_ATLAS_INDEX)

func clear_move_markers() -> void:
	for position: Vector2i in _marker_tilemap.get_surrounding_cells(character_positions[current_character]):
		if _marker_tilemap.get_cell_atlas_coords(position) == MOVE_MARKER_ATLAS_INDEX:
			_marker_tilemap.erase_cell(position)

func clear_index_markers() -> void:
	for position: Vector2i in character_positions.values():
		_marker_tilemap.erase_cell(position)

func intersects_character(coord: Vector2i) -> bool:
	for type in Character.values():
		if coord == character_positions[type]:
			return true
	return false
