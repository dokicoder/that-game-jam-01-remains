class_name Global extends Node

const tex_cable_right: Texture2D = preload("res://game/Aseprite/crossing_right.png")
const tex_cable_left: Texture2D = preload("res://game/Aseprite/crossing_left.png")
const tex_cable_top: Texture2D = preload("res://game/Aseprite/crossing_top.png")
const tex_cable_bottom: Texture2D = preload("res://game/Aseprite/crossing_bottom.png")

const tex_contacts_left: Texture2D = preload("res://game/Aseprite/contacts_left.png")
const tex_contacts_right: Texture2D = preload("res://game/Aseprite/contacts_right.png")
const tex_cover_left: Texture2D = preload("res://game/Aseprite/cover_left.png")
const tex_cover_right: Texture2D = preload("res://game/Aseprite/cover_right.png")


enum Orientation {
	LEFT, 
	RIGHT, 
	TOP,
	BOTTOM
}
