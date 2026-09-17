class_name GameManager
extends Node

signal increment_time(time: int)
signal decrement_time(time: int)
signal enemy_killed_at(coord: Vector2i, time: int)

static var instance: GameManager
static var RNG: RandomNumberGenerator = RandomNumberGenerator.new()
static var enemies: Array[EnemyController] = []
static var characters: Array[CharacterController] = []
static var time: int = 0

@export var max_actions_allowed: int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	RNG = RandomNumberGenerator.new()
	enemies = []
	characters = []
	time = 0

func _input(event: InputEvent) -> void:
	if Engine.time_scale == 0:
		return
	if event is InputEventMouseButton:
		if time < max_actions_allowed and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_released():
			time += 1
			increment_time.emit(time)
			if _all_enemies_dead():
				get_tree().quit()
		elif time > 0 and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_released():
			time -= 1
			decrement_time.emit(time)

func _all_enemies_dead() -> bool:
	for enemy: EnemyController in enemies:
		if not enemy.is_dead_at(time):
			return false
	return true
