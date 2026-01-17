@tool
extends PanelContainer

var cable_map: CableMap

@onready var texture: ColorRect = $VBox/HBoxContainer/Texture
@onready var x: SpinBox = $VBox/Resizer/X
@onready var y: SpinBox = $VBox/Resizer/Y

@onready var cable_button: Button = $VBox/HBoxContainer/VBoxContainer/Button_Cable

func _ready():
	_remove_built_in_preview.call_deferred()

	x.set_value_no_signal(cable_map.map_image.get_size().x)
	y.set_value_no_signal(cable_map.map_image.get_size().y)
	
	# TODO: this should pre-toggle the cable button
	#cable_button.pressed.emit.call_deferred()
	

func _on_size_changed():
	cable_map.map_image.resize(x.value, y.value, Image.Interpolation.INTERPOLATE_NEAREST)
	texture.update_size()


func _set_all_bits(value: bool):
	cable_map.map_image.fill(Color.WHITE if value else Color.BLACK)
	texture.queue_redraw()

func _remove_built_in_preview() -> void:
	# this is relevant when pverriding a resource type that already has a preview - keep that in mind
	pass
