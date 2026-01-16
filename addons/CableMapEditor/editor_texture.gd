@tool
extends ColorRect

var cable_map: CableMap

var pixel_size: float
var mouse_at: Vector2i
var pressed: bool = false

const color_none = Color.BLACK
const color_cable = Color("#220000")

func _ready() -> void:
	print("assigning")
	cable_map = owner.cable_map
	
	if not is_instance_valid(cable_map.map_image):
		cable_map.map_image = Image.create_empty(10, 10, false, Image.Format.FORMAT_L8)
	
	update_size.call_deferred()

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
	), Color("#ff0000"))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_at = event.position / pixel_size
		if pressed:
			_set_bit_under_mouse(event)
		queue_redraw()
	
	elif event is InputEventMouseButton:
		pressed = event.pressed
		if pressed:
			_set_bit_under_mouse(event)
			queue_redraw()

func _set_bit_under_mouse(event: InputEventMouse) -> void:
	cable_map.map_image.set_pixel(mouse_at.x, mouse_at.y, Color("#330000"))
