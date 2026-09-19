class_name TimeSlider
extends HSlider

@onready var _max_label: Label = $"../Label2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not GameManager.instance:
		await get_tree().create_timer(0.1).timeout
	max_value = GameManager.instance.max_actions_allowed
	tick_count = max_value / 10
	_max_label.text = str(GameManager.instance.max_actions_allowed)
	GameManager.instance.increment_time.connect(func (x): value = x)
	GameManager.instance.decrement_time.connect(func (x): value = x)
	value_changed.connect(_on_manual_change)

func _on_manual_change(value: float) -> void:
	var new_time: int = int(value)
	var increment_time: bool = true
	if new_time == GameManager.time:
		return
	elif new_time > GameManager.time:
		increment_time = true
	else:
		increment_time = false
	
	while GameManager.time != new_time:
		if increment_time:
			GameManager.time += 1
			GameManager.instance.increment_time.emit(GameManager.time)
		else:
			GameManager.time -= 1
			GameManager.instance.decrement_time.emit(GameManager.time)
