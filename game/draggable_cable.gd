extends Node2D

var is_hovered: bool = false
var is_dragging: bool = false
var is_snapped: bool = false
var _offset: Vector2 = Vector2(0.0, 0.0) 
var _snap_position: Vector2 = Vector2(0.0, 0.0) 

const HIGHLIGHT_SCALE = 1.01

const SNAP_DISTANCE = 20.0

func _input(event):
	if event is InputEventMouseButton:
		if is_hovered and event.button_index == MOUSE_BUTTON_LEFT:
			if not G.is_dragging and event.pressed:
				is_dragging = true
				z_index = 2
				# globally store this so there can only be one dragged object at once
				G.is_dragging = true
				_offset = get_global_mouse_position() - global_position
			elif is_dragging and not event.pressed:
				G.is_dragging = false
				z_index = 0
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
	
	if not G.is_dragging:
		is_hovered = true
		scale = Vector2(HIGHLIGHT_SCALE, HIGHLIGHT_SCALE)
		
func _on_area_2d_mouse_exited() -> void:
	print("exited")
	
	if not is_dragging:
		is_hovered = false
		scale = Vector2(1, 1)

func do_extensions_connect(a: Extension, b: Extension):
	if( a.orientation == G.Orientation.LEFT && b.orientation == G.Orientation.RIGHT
	or a.orientation == G.Orientation.RIGHT && b.orientation == G.Orientation.LEFT
	or a.orientation == G.Orientation.TOP && b.orientation == G.Orientation.BOTTOM
	or a.orientation == G.Orientation.BOTTOM && b.orientation == G.Orientation.TOP ):
		return a.with_contacts != b.with_contacts

func _on_extensions_entered(extension_from_this_cable: Extension, other_extension: Extension) -> void:
	print(extension_from_this_cable.name, " entered ", other_extension.name)
	
	if( is_dragging 
		and extension_from_this_cable.connected_extension == null
		and other_extension.connected_extension == null
		and do_extensions_connect(extension_from_this_cable, other_extension) 
	):
		extension_from_this_cable.connected_extension = other_extension
		other_extension.connected_extension = extension_from_this_cable
		extension_from_this_cable.hide_contacts()
		other_extension.hide_contacts()
		is_snapped = true
		
		# snap to position of extension
		_snap_position = get_global_mouse_position()
		scale = Vector2(1, 1)
		var extension_position_relative_to_cable = extension_from_this_cable.global_position - global_position
		global_position = other_extension.global_position - extension_position_relative_to_cable
	
func _on_extensions_exited(extension_from_this_cable: Extension, other_extension: Extension) -> void:
	# clear connection information, show contacts again
	if extension_from_this_cable.connected_extension == other_extension:
		extension_from_this_cable.connected_extension = null
		other_extension.connected_extension = null
		extension_from_this_cable.restore_contacts()
		other_extension.restore_contacts()
