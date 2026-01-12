@tool
class_name Core extends Node2D

@export var left_slot: bool:
	get: return $CableLeft.visible
	set(value):
		if not Engine.is_editor_hint():
			return
		if is_instance_valid($CableLeft):
			$CableLeft.visible = value
	
@export var right_slot: bool:
	get: return $CableRight.visible
	set(value): 
		if not Engine.is_editor_hint():
			return
		if is_instance_valid($CableRight):
			$CableRight.visible = value
	
@export var top_slot: bool:
	get: return $CableTop.visible
	set(value):
		if not Engine.is_editor_hint():
			return
		if is_instance_valid($CableTop):
			$CableTop.visible = value
	
@export var bottom_slot: bool:
	get: return $CableBottom.visible
	set(value):
		if not Engine.is_editor_hint():
			return
		if is_instance_valid($CableBottom):
			$CableBottom.visible = value
