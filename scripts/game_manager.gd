class_name GameManager
extends Node

signal increment_time(time: int)
signal decrement_time(time: int)

static var instance: GameManager
static var RNG: RandomNumberGenerator = RandomNumberGenerator.new()
static var enemies: Array[EnemyController] = []
static var characters: Array[CharacterController] = []

@export var max_actions_allowed: int = 100
var time: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if time < max_actions_allowed and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_released():
			time += 1
			increment_time.emit(time)
		elif time > 0 and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_released():
			time -= 1
			decrement_time.emit(time)

func _on_characters_killed() -> void:
	print("all characters killed")
	get_tree().quit()

func _on_enemies_killed() -> void:
	print("all enemies killed")
	get_tree().quit()
