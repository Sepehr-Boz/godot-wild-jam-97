extends Control

@export var _slides: Array[CanvasLayer] = []
@onready var _left_button: Button = $"Navigation Buttons/Left Button"
@onready var _right_button: Button = $"Navigation Buttons/Right Button"

var current_slide: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_left_button.pressed.connect(_on_left_button_press)
	_right_button.pressed.connect(_on_right_button_press)
	for i in len(_slides):
		if i == 0:
			show_slide(i)
		else:
			hide_slide(i)
	_left_button.visible = false
	_right_button.visible = len(_slides) > 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_left_button_press() -> void:
	if current_slide == 0:
		return
	hide_slide(current_slide)
	current_slide -= 1
	show_slide(current_slide)
	_left_button.visible = current_slide != 0
	_right_button.visible = current_slide != len(_slides) - 1

func _on_right_button_press() -> void:
	if current_slide == len(_slides) - 1:
		return
	hide_slide(current_slide)
	current_slide += 1
	show_slide(current_slide)
	_left_button.visible = current_slide != 0
	_right_button.visible = current_slide != len(_slides) - 1

func hide_slide(slide_index: int) -> void:
	_slides[slide_index].visible = false

func show_slide(slide_index: int) -> void:
	_slides[slide_index].visible = true
