@tool
class_name Extension extends Node2D

var toggle: G.Orientation = G.Orientation.LEFT

@export var orientation: G.Orientation:
	get: return _orientation
	set(value): 
		_orientation = value
		update_orientation()
		
@export var with_contacts: bool:
	get: return $Root/Contacts.visible
	set(value):
		$Root/Contacts.visible = value

var _orientation: G.Orientation = G.Orientation.LEFT

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
			
