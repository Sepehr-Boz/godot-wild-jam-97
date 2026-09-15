class_name GameManager
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CharacterController.instance.characters_killed.connect(_on_characters_killed)
	EnemyController.instance.enemies_killed.connect(_on_enemies_killed)

func _on_characters_killed() -> void:
	print("all characters killed")
	get_tree().quit()

func _on_enemies_killed() -> void:
	print("all enemies killed")
	get_tree().quit()
