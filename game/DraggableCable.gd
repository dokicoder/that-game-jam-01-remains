extends Node2D

var is_hovered: bool = false
var is_dragging: bool = false
var _offset: Vector2 = Vector2(0.0, 0.0) 

const HIGHLIGHT_SCALE = 1.005


func _input(event):
	if event is InputEventMouseButton:
		if is_hovered and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			if event.pressed:
				_offset = get_global_mouse_position() - global_position
			print("pressed ", event.pressed)

func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - _offset

func _on_area_2d_mouse_entered() -> void:
	print("entered")
	
	is_hovered = true
	scale = Vector2(HIGHLIGHT_SCALE, HIGHLIGHT_SCALE)
		
func _on_area_2d_mouse_exited() -> void:
	print("exited")
	
	is_hovered = false
	scale = Vector2(1, 1)
