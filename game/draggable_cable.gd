extends Node2D

var is_hovered: bool = false
var is_dragging: bool = false
var is_snapped: bool = false
var _offset: Vector2 = Vector2(0.0, 0.0) 
var _snap_position: Vector2 = Vector2(0.0, 0.0) 

const HIGHLIGHT_SCALE = 1.005

const SNAP_DISTANCE = 50.0

func _input(event):
	if event is InputEventMouseButton:
		if is_hovered and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			if event.pressed:
				_offset = get_global_mouse_position() - global_position
			else:
				is_dragging = false
				is_snapped = false

func _process(delta: float) -> void:
	if is_dragging and not is_snapped:
		global_position = get_global_mouse_position() - _offset
	if is_dragging and is_snapped:
		if get_global_mouse_position().distance_to(_snap_position) > SNAP_DISTANCE:
			is_snapped = false

func _on_area_2d_mouse_entered() -> void:
	print("entered")
	
	if not is_dragging:
		is_hovered = true
		scale = Vector2(HIGHLIGHT_SCALE, HIGHLIGHT_SCALE)
		
func _on_area_2d_mouse_exited() -> void:
	print("exited")
	
	if not is_dragging:
		is_hovered = false
		scale = Vector2(1, 1)

func _on_extensions_entered(extension_from_this_cable: Extension, other_extension: Extension) -> void:
	print(extension_from_this_cable.name, " entered ", other_extension.name)
	
	if is_dragging:
		is_snapped = true
		_snap_position = get_global_mouse_position()
		scale = Vector2(1, 1)
		var extension_position_relative_to_cable = extension_from_this_cable.global_position - global_position
		global_position = other_extension.global_position - extension_position_relative_to_cable
	
func _on_extensions_exited(extension_from_this_cable: Extension, other_extension: Extension) -> void:
	pass # Replace with function body.
