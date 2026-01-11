@tool
class_name Extension extends Area2D

var toggle: G.Orientation = G.Orientation.LEFT

signal other_intersection_entered(this: Extension, other: Extension)
signal other_intersection_exited(this: Extension, other: Extension)

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
		
		$Root/Contacts.visible = value

var _orientation: G.Orientation = G.Orientation.LEFT
var _with_contacts: bool = false

func _ready():
	# TODO: why is this needed?
	update_orientation()
	print("init with contatcs ", _with_contacts)
	$Root/Contacts.visible = _with_contacts

func update_orientation():
	print_debug("update_orientation")

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

func _on_area_entered(other: Area2D) -> void:
	other_intersection_entered.emit(self, other as Extension)

func _on_area_exited(other: Area2D) -> void:
	other_intersection_exited.emit(self, other as Extension)
