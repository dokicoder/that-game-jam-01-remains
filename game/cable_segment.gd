@tool
class_name CableSegment extends Node2D

@export_tool_button("Flow Energy", "OmniLight3D") var flow_action = flow_energy

@export_range(0, 10) var energy_level: float = 0:
	get: return _energy_level
	set(value): 
		var clamped_value = clamp(value, -1, 3)
		_energy_level = clamped_value
		_get_sprite().modulate = _energy_level_to_color(clamped_value)

@export var source_drain_amount: float

var energy_color_curve: Curve = preload("uid://bojq15sjqlojl")

var _energy_level: float = 0

var adjacent_segments: Array[CableSegment] = []

var _t: float = 0.0
const FLOW_ENRGY_INTERVAL: float = 0.05

func flow_energy():
	energy_level += source_drain_amount

	var num_lower_energy_segments = 0
	var total_energy = energy_level
	
	for segment in adjacent_segments:
		if segment.energy_level < energy_level:
			total_energy += segment.energy_level
			num_lower_energy_segments += 1

	var average_energy = total_energy / (num_lower_energy_segments + 1)

	for segment in adjacent_segments:
		if segment.energy_level < energy_level:
			segment.energy_level = average_energy

	energy_level = average_energy

func _process(delta) -> void:
	_t += delta
	if _t >= FLOW_ENRGY_INTERVAL:
		_t -= FLOW_ENRGY_INTERVAL

		flow_energy()
 
func _energy_level_to_color(energy_level: float) -> Color:	
	var color_vector = Vector3(
		1,
		1,
		energy_color_curve.sample(energy_level) + 1,
	)
		
	color_vector = color_vector.normalized() * sqrt(3.0)
	
	return Color(color_vector.x, color_vector.y, color_vector.z)

# override this if the path to the texture is different
func _get_sprite():
	# in default cable scene, the root itself is the Sprite2D
	return self

func generate_collision_polygon():
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(_get_sprite().texture.get_image())
	bitmap.grow_mask(2, Rect2(Vector2(0, 0), bitmap.get_size()))
	
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()), 3)

	for polygon in polygons:
		if Geometry2D.is_polygon_clockwise(polygon):
			# todo: won't work for other dimension tiles
			return Transform2D(0, Vector2(-16.0, -16.0)) * polygon
	return null
