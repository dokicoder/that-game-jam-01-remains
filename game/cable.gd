@tool
class_name Cable extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var is_hovered: bool = false
var is_dragging: bool = false
var is_snapped: bool = false
var _offset: Vector2 = Vector2(0.0, 0.0) 
var _snap_position: Vector2 = Vector2(0.0, 0.0) 

const HIGHLIGHT_SCALE = 1.01
const SNAP_DISTANCE = 20.0

var _is_rotating: bool = false

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
		if is_dragging && !_is_rotating && event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
			var tween = get_tree().create_tween()

			_is_rotating = true

			tween.finished.connect(func():
				_is_rotating = false
			)
			
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_ELASTIC)
			tween.tween_property(self, "rotation", rotation + PI * 0.5, 0.4)
				
func _process(delta: float) -> void:
	if is_dragging and not is_snapped:
		global_position = get_global_mouse_position() - _offset
	if is_dragging and is_snapped:
		# unsnapping when moving out of a certain radius
		if get_global_mouse_position().distance_to(_snap_position) > SNAP_DISTANCE:
			is_snapped = false

func _on_area_2d_mouse_entered() -> void:
	#print_debug("entered")
	if not G.is_dragging:
		is_hovered = true
		scale = Vector2(HIGHLIGHT_SCALE, HIGHLIGHT_SCALE)
		
func _on_area_2d_mouse_exited() -> void:
	#print_debug("exited")
	
	if not is_dragging:
		is_hovered = false
		scale = Vector2(1, 1)

# do connectors face in the opposite direction and have opposite connectors
func do_connectors_connect(a: Connector, b: Connector):
	if a.with_contacts != b.with_contacts:
		return ( a.relative_orientation() == G.Orientation.LEFT && b.relative_orientation() == G.Orientation.RIGHT
			  or a.relative_orientation() == G.Orientation.RIGHT && b.relative_orientation() == G.Orientation.LEFT
			  or a.relative_orientation() == G.Orientation.TOP && b.relative_orientation() == G.Orientation.BOTTOM
			  or a.relative_orientation() == G.Orientation.BOTTOM && b.relative_orientation() == G.Orientation.TOP )

func snap_connectors_together(connector_from_this_cable: Connector, other_connector: Connector):
	connector_from_this_cable.connected_connector = other_connector
	other_connector.connected_connector = connector_from_this_cable
	connector_from_this_cable.hide_contacts()
	other_connector.hide_contacts()
	is_snapped = true
	
	audio_stream_player.pitch_scale = 0.95 + 0.1 * randf()
	audio_stream_player.play()
	
	# snap to position of connector
	_snap_position = get_global_mouse_position()
	scale = Vector2(1, 1)
	var connector_position_relative_to_cable = connector_from_this_cable.global_position - global_position
	global_position = other_connector.global_position - connector_position_relative_to_cable

func _on_connectors_entered(connector_from_this_cable: Connector, other_connector: Connector) -> void:
	if( is_dragging 
		# only if connecters are free, i.e. not already connected to some other connector
		and connector_from_this_cable.connected_connector == null
		and other_connector.connected_connector == null
		and do_connectors_connect(connector_from_this_cable, other_connector) 
	):
		snap_connectors_together(connector_from_this_cable, other_connector)
		
	
func _on_connectors_exited(connector_from_this_cable: Connector, other_connector: Connector) -> void:
	# clear connection information, show contacts again
	if connector_from_this_cable.connected_connector == other_connector:
		connector_from_this_cable.connected_connector = null
		other_connector.connected_connector = null
		connector_from_this_cable.restore_contacts()
		other_connector.restore_contacts()
