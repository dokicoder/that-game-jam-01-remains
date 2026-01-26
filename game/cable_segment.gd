@tool
class_name CableSegment extends Node2D

# override this if the path to the texture is different
func _get_texture():
	return self.texture

func generate_collision_polygon():
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(_get_texture().get_image())
	bitmap.grow_mask(2, Rect2(Vector2(0, 0), bitmap.get_size()))
	
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()), 3)

	for polygon in polygons:
		if Geometry2D.is_polygon_clockwise(polygon):
			# todo: won't work for other dimension tiles
			return Transform2D(0, Vector2(-16.0, -16.0)) * polygon
	return null
