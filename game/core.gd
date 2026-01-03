extends Sprite2D

@export var left_slot: bool:
	get: return cable_left.visible
	set(value): cable_left.visible = value
	
@export var right_slot: bool:
	get: return cable_right.visible
	set(value): cable_right.visible = value
	
@export var top_slot: bool:
	get: return cable_top.visible
	set(value): cable_top.visible = value
	
@export var bottom_slot: bool:
	get: return cable_bottom.visible
	set(value): cable_bottom.visible = value

@onready var cable_left: Extension = $CableLeft
@onready var cable_right: Extension = $CableRight
@onready var cable_top: Extension = $CableTop
@onready var cable_bottom: Extension = $CableBottom
