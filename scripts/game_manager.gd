class_name GameManager
extends Node

signal increment_time()
signal decrement_time()

static var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_released():
			increment_time.emit()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_released():
			decrement_time.emit()
	elif event.is_action_pressed("show_tips"):
		pass
	elif event.is_action_released("show_tips"):
		pass

func _on_characters_killed() -> void:
	print("all characters killed")
	get_tree().quit()

func _on_enemies_killed() -> void:
	print("all enemies killed")
	get_tree().quit()
