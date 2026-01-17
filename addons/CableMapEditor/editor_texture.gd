@tool
extends ColorRect

var cable_map: CableMap

var pixel_size: float
var mouse_at: Vector2i
var pressed: bool = false

const color_none = Color.BLACK

var selected_color: Color = COLOR_CABLE

var is_painting: bool = false

const COLOR_CONNECTOR: Color = Color("#b43f2a")
const COLOR_CABLE: Color = Color("#007b3a")
const COLOR_CABLE_HORIZONTAL: Color = Color("#00de0c")
const COLOR_CABLE_VERTICAL: Color = Color("003124")
const COLOR_BACKGROUND: Color = Color("#000000")

func _on_select_color(color: String):
	selected_color = color

func _ready() -> void:
	cable_map = owner.cable_map
	update_size.call_deferred()
	
	# no cable map assigned
	if not is_instance_valid(cable_map):
		return
	
	if not is_instance_valid(cable_map.map_image):
		print_debug("resource had no image, initializing with default empty image")
		cable_map.map_image = Image.create_empty(10, 10, false, Image.Format.FORMAT_RGB8)
	


func update_size() -> void:
	pixel_size = get_parent().size.x / float(cable_map.map_image.get_size().x)
	custom_minimum_size = Vector2(cable_map.map_image.get_size()) * pixel_size
	queue_redraw()

func _draw() -> void:	
	for x: int in cable_map.map_image.get_size().x:
		for y: int in cable_map.map_image.get_size().y:
			var pixel_color = cable_map.map_image.get_pixel(x, y)

			draw_rect(
				Rect2(
					Vector2(x, y) * pixel_size,
					Vector2(pixel_size, pixel_size)
				), pixel_color)
	
	draw_rect(Rect2(
		mouse_at * pixel_size,
		Vector2(pixel_size, pixel_size)
	), selected_color)

	draw_rect(Rect2(
		mouse_at * pixel_size,
		Vector2(pixel_size, pixel_size)
	), Color.WHITE, false)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_painting = event.pressed
		queue_redraw()
	if event is InputEventMouseMotion:
		mouse_at = event.position / pixel_size
		if is_painting:
			_set_bit_under_mouse(event)
		queue_redraw()

func _set_bit_under_mouse(event: InputEventMouse) -> void:
	cable_map.map_image.set_pixel(mouse_at.x, mouse_at.y, selected_color)
