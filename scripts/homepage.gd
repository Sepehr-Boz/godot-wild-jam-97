extends CanvasLayer

@export var _npc_source_indices: Array[int] = []
@onready var _ground_tilemap: TileMapLayer = $Ground
@onready var _npc_tilemap: TileMapLayer = $NPCs
@onready var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

const LEVEL_BOUND_START: Vector2i = Vector2i.ZERO
const LEVEL_BOUND_END: Vector2i = Vector2i(15, 8)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_npc_tilemap.clear()
	for i in len(_npc_source_indices):
		var position: Vector2i = _spawn_character(i)
		_move_character(position, _npc_source_indices[i])

func _spawn_character(npc_source_index_index: int) -> Vector2i:
	var spawn_position: Vector2i = Vector2i(
		_rng.randi_range(LEVEL_BOUND_START.x, LEVEL_BOUND_END.x),
		npc_source_index_index)
	_npc_tilemap.set_cell(
		spawn_position,
		_npc_source_indices[npc_source_index_index],
		Vector2i.ZERO)
	return spawn_position

func _move_character(character_index: Vector2i, character_source: int) -> void:
	var move_interval: float = _rng.randf_range(1.0, 3.0)
	var moving_right: bool = (_rng.randi_range(0, 1) == 1)
	while true:
		await get_tree().create_timer(move_interval).timeout
		_npc_tilemap.erase_cell(character_index)
		if character_index.x == LEVEL_BOUND_END.x:
			moving_right = false
		elif character_index.x == LEVEL_BOUND_START.x:
			moving_right = true
		character_index.x += 1 if moving_right else -1
		_npc_tilemap.set_cell(character_index, character_source, Vector2i.ZERO)
