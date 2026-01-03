class_name Extension extends Node2D

@onready var root_node: Node2D = $Root
@onready var cover: Sprite2D = $Root/Cover
@onready var contacts: Sprite2D = $Root/Contacts
@onready var cable: Sprite2D = $Cable
@onready var timer: Timer = $Timer

var toggle: G.Orientation = G.Orientation.LEFT

@export var orientation: G.Orientation:
	get: return _orientation
	set(value): 
		_orientation = value
		update_orientation()
		
@export var with_contacts: bool:
	get: return _with_contacts
	set(value): 
		_with_contacts = value
		contacts.visible = _with_contacts

var _orientation: G.Orientation = G.Orientation.LEFT
var _with_contacts: bool = true

func update_orientation():
	match _orientation:
		G.Orientation.LEFT:
			cable.texture = G.tex_cable_left
		G.Orientation.RIGHT:
			cable.texture = G.tex_cable_right
		G.Orientation.TOP:
			cable.texture = G.tex_cable_top
		G.Orientation.BOTTOM:
			cable.texture = G.tex_cable_bottom
			
	match _orientation:
		G.Orientation.LEFT, G.Orientation.TOP:
			cover.texture = G.tex_cover_left
			contacts.texture = G.tex_contacts_right
			root_node.rotation = 0
		G.Orientation.RIGHT, G.Orientation.BOTTOM:
			cover.texture = G.tex_cover_right
			contacts.texture = G.tex_contacts_left
			
	match _orientation:
		G.Orientation.TOP, G.Orientation.BOTTOM:
			root_node.rotation = PI * 0.5
		G.Orientation.LEFT, G.Orientation.RIGHT:
			root_node.rotation = 0
			

func _ready() -> void:
	timer.timeout.connect(_on_timeout)
	timer.start()

func _on_timeout() -> void:
	pass
	match orientation:
		G.Orientation.TOP:
			orientation = G.Orientation.RIGHT
		G.Orientation.RIGHT:
			orientation = G.Orientation.BOTTOM
		G.Orientation.BOTTOM:
			orientation = G.Orientation.LEFT
		G.Orientation.LEFT:
			orientation = G.Orientation.TOP
	
