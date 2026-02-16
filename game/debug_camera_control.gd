extends Node2D

var click_position: Vector2
var start_camera_position: Vector2
var _is_dragging_camera = false

var CAMERA_DRAG_SPEED = 0.2

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_is_dragging_camera = true
			click_position = get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			_is_dragging_camera = false

func _process(delta: float) -> void:
	if _is_dragging_camera:
		self.global_position += ( click_position - get_global_mouse_position()) * CAMERA_DRAG_SPEED
