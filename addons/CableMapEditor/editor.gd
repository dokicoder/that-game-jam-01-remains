@tool
extends PanelContainer

var cable_map: CableMap

@onready var texture: ColorRect = $VBox/Texture
@onready var x: SpinBox = $VBox/Resizer/X
@onready var y: SpinBox = $VBox/Resizer/Y


func _ready():
	_remove_built_in_preview.call_deferred()

	x.set_value_no_signal(cable_map.map_image.get_size().x)
	y.set_value_no_signal(cable_map.map_image.get_size().y)


func _on_size_changed():
	cable_map.map_image.resize(x.value, y.value)
	texture.update_size()


func _set_all_bits(value: bool):
	cable_map.map_image.fill(Color.WHITE if value else Color.BLACK)
	texture.queue_redraw()

func _remove_built_in_preview() -> void:
	var previous_ui = get_parent().get_child(get_index() + 1)
	
	if is_instance_valid(previous_ui):
		previous_ui.queue_free()
