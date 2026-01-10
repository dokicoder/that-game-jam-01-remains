@tool
class_name Core extends Sprite2D

@export var left_slot: bool:
	get: return $CableLeft.visible
	set(value): 
		if not Engine.is_editor_hint():
			return
		$CableLeft.visible = value
	
@export var right_slot: bool:
	get: return $CableRight.visible
	set(value): 
		if not Engine.is_editor_hint():
			return
		$CableRight.visible = value
	
@export var top_slot: bool:
	get: return $CableTop.visible
	set(value):
		if not Engine.is_editor_hint():
			return
		$CableTop.visible = value
	
@export var bottom_slot: bool:
	get: return $CableBottom.visible
	set(value):
		if not Engine.is_editor_hint():
			return
		$CableBottom.visible = value
