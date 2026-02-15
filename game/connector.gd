@tool
class_name Connector extends CableSegment

signal other_intersection_entered(this: Connector, other: Connector)
signal other_intersection_exited(this: Connector, other: Connector)

@export var orientation: G.Orientation:
	get: return _orientation
	set(value): 
		_orientation = value
		if not Engine.is_editor_hint():
			return
		update_orientation()
		
@export var with_contacts: bool:
	get: return _with_contacts
	set(value):
		_with_contacts = value
		if not Engine.is_editor_hint():
			return
		$Root/Contacts.visible = value

var connected_connector: Connector = null

func get_adjacent_segments():
	if connected_connector: 
		var neighbors_including_connected_connector = [connected_connector]
		neighbors_including_connected_connector.append_array(adjacent_segments)
		return neighbors_including_connected_connector

	return adjacent_segments

var _orientation: G.Orientation = G.Orientation.LEFT
var _with_contacts: bool = false

# relative to rotation
func relative_orientation():
	var rotation_offset: int = round( fmod(global_rotation, PI * 2) / (PI * 0.5) )
	
	var initial_index = {
		G.Orientation.LEFT: 0,
		G.Orientation.TOP: 1,
		G.Orientation.RIGHT: 2,
		G.Orientation.BOTTOM: 3,
	}[orientation]

	var index = (initial_index + rotation_offset + 4) % 4
	var new_orientation = [G.Orientation.LEFT, G.Orientation.TOP, G.Orientation.RIGHT, G.Orientation.BOTTOM][index]

	#print_debug("initial orientation: ", G.Orientation.keys()[orientation])
	#print_debug("updated orientation: ", G.Orientation.keys()[new_orientation])

	return new_orientation

# override of method in base class CableSegment
func _get_sprite():
	return $Cable

# hide contacts without changin visible, used e.g. for snapping
func hide_contacts():
	$Root/Contacts.visible = false
	
func restore_contacts():
	$Root/Contacts.visible = _with_contacts

func _ready():
	# TODO: why is this needed?
	update_orientation()
	#print_debug("init with contatcs ", _with_contacts)
	$Root/Contacts.visible = _with_contacts

func update_orientation():
	#print_debug("update_orientation")

	match _orientation:
		G.Orientation.LEFT:
			$Cable.texture = G.tex_cable_right
		G.Orientation.RIGHT:
			$Cable.texture = G.tex_cable_left
		G.Orientation.TOP:
			$Cable.texture = G.tex_cable_bottom
		G.Orientation.BOTTOM:
			$Cable.texture = G.tex_cable_top
			
	match _orientation:
		G.Orientation.RIGHT, G.Orientation.BOTTOM:
			$Root/Cover.texture = G.tex_cover_left
			$Root/Contacts.texture = G.tex_contacts_right
			$Root/Cover.rotation = 0
		G.Orientation.LEFT, G.Orientation.TOP:
			$Root/Cover.texture = G.tex_cover_right
			$Root/Contacts.texture = G.tex_contacts_left
			
	match _orientation:
		G.Orientation.TOP, G.Orientation.BOTTOM:
			$Root.rotation = PI * 0.5
		G.Orientation.LEFT, G.Orientation.RIGHT:
			$Root.rotation = 0

func _on_area_entered(other: Connector) -> void:
	other_intersection_entered.emit(self, other as Connector)

func _on_area_exited(other: Connector) -> void:
	other_intersection_exited.emit(self, other as Connector)
