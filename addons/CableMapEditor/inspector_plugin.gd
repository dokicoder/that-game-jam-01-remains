extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is CableMap

func _parse_begin(object: Object) -> void:
	var editor = preload("res://addons/CableMapEditor/editor.tscn").instantiate()
	editor.cable_map = object
	add_custom_control(editor)
