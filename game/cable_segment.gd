@tool
class_name CableSegment extends Node2D

var _energy_level: float = 0

static func _energy_level_to_color(energy_level: float) -> Color:
	var amount = abs(energy_level) / 100 + 1
	
	var color_vector = Vector3(
		amount if energy_level < 0 else 1,
		1,
		amount if energy_level >= 0 else 1,
		 )
		
	color_vector = color_vector.normalized() * sqrt(3.0)
	
	return Color(color_vector.x, color_vector.y, color_vector.z)

@export_range(-100, 100, 1, "or_less", "or_greater") var energy_level: float = 0:
	get: return _energy_level
	set(value): 
		_energy_level = value
		_get_sprite().modulate = _energy_level_to_color(value)

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
