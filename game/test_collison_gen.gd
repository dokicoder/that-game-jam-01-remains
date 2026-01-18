@tool
extends Sprite2D

@export var other_collider: CollisionPolygon2D

@export_tool_button("Generate") var action_gen = generate_collision_shape
@export_tool_button("Join") var action_join = join_with_other_collider

func generate_collision_shape():
	print("generate_collision_shape")
	var image = texture.get_image()

	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	bitmap.grow_mask(2, Rect2(Vector2(0, 0), bitmap.get_size()))

	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()), 3)

	for c in get_children():
		c.queue_free()

	for polygon in polygons:
		
		if Geometry2D.is_polygon_clockwise(polygon):
			print("=> Clockwise")
			var collider = CollisionPolygon2D.new()
			collider.polygon = polygon
			collider.position.x = -16
			collider.position.y = -16
			add_child(collider)
			
			collider.owner = get_tree().edited_scene_root
		else:
			print(": Counterclockwise")

func join_with_other_collider():
	print("join_with_other_collider")
	var c_this: CollisionPolygon2D = get_child(0)

	var polygons = Geometry2D.merge_polygons(c_this.polygon, other_collider.polygon)

	for polygon in polygons:
		
		if Geometry2D.is_polygon_clockwise(polygon):
			print("=> Clockwise")
			c_this.polygon = polygon
		else:
			print(": Counterclockwise")
