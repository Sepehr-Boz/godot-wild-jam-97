class_name TileMapPath
extends TileMapLayer

enum LoopType { NONE, TURN_AROUND, LOOP }
enum Marker {
	UP_ARROW, DOWN_ARROW, LEFT_ARROW, RIGHT_ARROW,
	CURVE_RD, CURVE_RU, CURVE_LD, CURVE_LU,
	HORIZONTAL, VERTICAL }

const MARKER_ATLAS_INDEX: Dictionary[Marker, Vector2i] = {
	Marker.UP_ARROW: Vector2i(4, 2),
	Marker.DOWN_ARROW: Vector2i(4, 4),
	Marker.LEFT_ARROW: Vector2i(5, 2),
	Marker.RIGHT_ARROW: Vector2i(7, 2),
	Marker.CURVE_RD: Vector2i(5, 3),
	Marker.CURVE_RU: Vector2i(5, 4),
	Marker.CURVE_LD: Vector2i(6, 3),
	Marker.CURVE_LU: Vector2i(6, 4),
	Marker.HORIZONTAL: Vector2i(6, 2),
	Marker.VERTICAL: Vector2i(4, 3),
}

@export var points: Array[Vector2i] = []
@export var loop_type: LoopType = LoopType.NONE
var current_time: int = 0
var _move_forward: bool = true

func increment_time() -> void:
	if loop_type == LoopType.NONE:
		current_time += 1
		current_time = clampi(current_time, 0, len(points) - 1)
	elif loop_type == LoopType.LOOP:
		current_time += 1
		current_time %= len(points)
	elif loop_type == LoopType.TURN_AROUND:
		if _move_forward:
			current_time += 1
		else:
			current_time -= 1
		if current_time == len(points) - 1:
			_move_forward = false
		elif current_time == 0:
			_move_forward = true

func get_current_point() -> Vector2i:
	return points[current_time]

func hide_path() -> void:
	visible = false

func show_path() -> void:
	visible = true
