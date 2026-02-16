class_name Global extends Node

const tex_cable_right: Texture2D = preload("res://game/Aseprite/crossing_right.png")
const tex_cable_left: Texture2D = preload("res://game/Aseprite/crossing_left.png")
const tex_cable_top: Texture2D = preload("res://game/Aseprite/crossing_top.png")
const tex_cable_bottom: Texture2D = preload("res://game/Aseprite/crossing_bottom.png")

const tex_contacts_left: Texture2D = preload("res://game/Aseprite/contacts_left.png")
const tex_contacts_right: Texture2D = preload("res://game/Aseprite/contacts_right.png")
const tex_cover_left: Texture2D = preload("res://game/Aseprite/cover_left.png")
const tex_cover_right: Texture2D = preload("res://game/Aseprite/cover_right.png")

const tex_cable_h: Texture2D = preload("res://game/Aseprite/cable_segment_h.png")
const tex_cable_v: Texture2D = preload("res://game/Aseprite/cable_segment_v.png")
const tex_cable_corner_top_left: Texture2D = preload("res://game/Aseprite/corner_top_to_left.png")
const tex_cable_corner_top_right: Texture2D = preload("res://game/Aseprite/corner_top_to_right.png")
const tex_cable_corner_bottom_left: Texture2D = preload("res://game/Aseprite/corner_bottom_to_left.png")
const tex_cable_corner_bottom_right: Texture2D = preload("res://game/Aseprite/corner_bottom_to_right.png")

const tex_cable_crossing: Texture2D = preload("res://game/Aseprite/cable_crossing.png")
const tex_cable_junction_1: Texture2D = preload("res://game/Aseprite/cable_junction.png")
const tex_cable_junction_2: Texture2D = preload("res://game/Aseprite/cable_junction2.png")

const tex_crossing_x_left: Texture2D = preload("res://game/Aseprite/three_way_x_left.png")
const tex_crossing_x_right: Texture2D = preload("res://game/Aseprite/three_way_x_right.png")
const tex_crossing_x_top: Texture2D = preload("res://game/Aseprite/three_way_x_top.png")
const tex_crossing_x_bottom: Texture2D = preload("res://game/Aseprite/three_way_x_bottom.png")

# Load the custom images for the mouse cursor.
const CURSOR_POINTER = preload("res://game/Aseprite/cable_junction2.png")
const CURSOR_HOVER = preload("res://game/Aseprite/cable_segment_h.png")
const CURSOR_DRAGGING = preload("res://game/Aseprite/cable_segment_v.png")


var is_dragging: bool:
	set(value):
		_is_dragging = value
		#Input.set_custom_mouse_cursor(CURSOR_POINTER if _is_dragging else CURSOR_HOVER)
	get():
		return _is_dragging

var _is_dragging: bool = false

enum Orientation {
	LEFT, 
	RIGHT, 
	TOP,
	BOTTOM
}

#func _ready():
	#Input.set_custom_mouse_cursor(CURSOR_POINTER)
