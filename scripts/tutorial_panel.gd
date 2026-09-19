extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			Engine.time_scale = 1
			visible = false
