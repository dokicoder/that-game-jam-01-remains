@tool
class_name GeneratedCable extends DraggableCable

var CableSegment: PackedScene = preload("res://game/CableSegment.tscn")
var Extension: PackedScene = preload("res://game/Extension.tscn")

@export_tool_button("Generate from Map", "Reload") var generate_action = _generate_cable_from_map

@export_tool_button("Generate Collider", "Collider") var generate_collider = _generate_collision_shape

const COLOR_CONNECTOR: Color = Color("#b43f2a")
const COLOR_CABLE: Color = Color("#007b3a")
const COLOR_CABLE_HORIZONTAL: Color = Color("#00de0c")
const COLOR_CABLE_VERTICAL: Color = Color("003124")
const COLOR_BACKGROUND: Color = Color("#000000")

const sprite_width: float = 32
const sprite_height: float = 32

func update_owner(node: Node):
	node.owner = get_tree().edited_scene_root

func get_map_pixel(x: int, y: int):
	if x < 0 or y < 0 or x >= cable_map.map_image.get_width() or y >= cable_map.map_image.get_height():
		return null
		
	return cable_map.map_image.get_pixel(x, y)
	
func get_neighbors(x: int, y: int):
	# [left, right, top, bottom]
	return [get_map_pixel(x - 1, y), get_map_pixel(x + 1, y), get_map_pixel(x, y - 1), get_map_pixel(x, y + 1)]

func _generate_collision_shape():
	print("_generate_collision_shape")
	
	var cable_segments_root: Node2D = $CableSegmentsRoot;
	
	var area_2d: Area2D = $Area2D;

	if not is_instance_valid(area_2d):
		area_2d = Area2D.new()
		area_2d.name = "Area2D"
		self.add_child(area_2d)
		
		update_owner(area_2d)

	area_2d.mouse_entered.connect( _on_area_2d_mouse_entered, ConnectFlags.CONNECT_PERSIST )
	area_2d.mouse_exited.connect( _on_area_2d_mouse_exited, ConnectFlags.CONNECT_PERSIST )
	
	for node in area_2d.get_children():
		node.queue_free()

	for node in cable_segments_root.get_children():
		#print("type: ", node.get_class())
		
		if not is_instance_valid(node):
			print("invalid instance - skipping")
			continue
		if not node.has_method("generate_collision_polygon"):
			print("generate_collision_polygon() does not exist - skipping")
			continue	

		var new_polygon = node.generate_collision_polygon()

		var collider = CollisionPolygon2D.new()
		collider.polygon = new_polygon
		area_2d.add_child(collider)
		
		collider.global_position = node.global_position
		
		update_owner(collider)

func create_cable_segment(position_x: float, position_y: float) -> CableSegment:
	var cable_segments_root: Node2D = $CableSegmentsRoot;

	if not is_instance_valid(cable_segments_root):
		cable_segments_root = Node2D.new()
		cable_segments_root.name = "CableSegmentsRoot"
		self.add_child(cable_segments_root)

		update_owner(cable_segments_root)
		
	var cable: Sprite2D = CableSegment.instantiate()
	cable_segments_root.add_child(cable)
	cable.name = "Cable"
	cable.position.x = position_x
	cable.position.y = position_y
	
	cable_segments_root.position.x += position_x
	cable_segments_root.position.y += position_y

	update_owner(cable)

	return cable

func _generate_cable_from_map():
	print("_generate_cable_from_map")
	
	if not is_instance_valid(cable_map) or not is_instance_valid(cable_map.map_image):
		print("no cable map to generate from, skipping")
		return
	


	var num_nodes: int = 0
	
	var cable_segments_root: Node2D = $CableSegmentsRoot;

	if not is_instance_valid(cable_segments_root):
		cable_segments_root = Node2D.new()
		cable_segments_root.name = "CableSegmentsRoot"
		self.add_child(cable_segments_root)
		
	update_owner(cable_segments_root)
	
	cable_segments_root.position.x = 0
	cable_segments_root.position.y = 0
	
	for node in cable_segments_root.get_children():
		node.queue_free()
	
	for x: int in cable_map.map_image.get_size().x:
		for y: int in cable_map.map_image.get_size().y:
			var pixel_color = cable_map.map_image.get_pixel(x, y)
			
			var neighbors = get_neighbors(x, y)
	
			match pixel_color:
				COLOR_CONNECTOR:	
					#print( "Position %d %d - Connector" %  [x, y] )
					var extension: Extension = Extension.instantiate()
					cable_segments_root.add_child(extension)
					extension.name = "Extension"
					cable_segments_root.move_child(extension, 0)
					num_nodes += 1
					
					if neighbors[0] == COLOR_CABLE or neighbors[0] == COLOR_CONNECTOR:
						extension.orientation = G.Orientation.RIGHT
					elif neighbors[1] == COLOR_CABLE or neighbors[1] == COLOR_CONNECTOR:
						extension.orientation = G.Orientation.LEFT
					elif neighbors[2] == COLOR_CABLE or neighbors[2] == COLOR_CONNECTOR:
						extension.orientation = G.Orientation.BOTTOM
					elif neighbors[3] == COLOR_CABLE or neighbors[3] == COLOR_CONNECTOR:
						extension.orientation = G.Orientation.TOP
						
					extension.position.x = x * sprite_width
					extension.position.y = y * sprite_height
				
					cable_segments_root.position.x += x * sprite_width
					cable_segments_root.position.y += y * sprite_height
						
					update_owner(extension)

					extension.other_intersection_entered.connect( _on_extensions_entered, ConnectFlags.CONNECT_PERSIST )
					extension.other_intersection_exited.connect( _on_extensions_exited, ConnectFlags.CONNECT_PERSIST )
					
				COLOR_CABLE:
					#print( "Position %d %d - Cable" %  [x, y] )
					var cable = create_cable_segment( x * sprite_width, y * sprite_height)
					num_nodes += 1
					
					var horizontal = (neighbors[0] == COLOR_CABLE or neighbors[0] == COLOR_CONNECTOR or neighbors[0] == COLOR_CABLE_HORIZONTAL) and (neighbors[1] == COLOR_CABLE or neighbors[1] == COLOR_CONNECTOR or neighbors[1] == COLOR_CABLE_HORIZONTAL)
					var vertical = (neighbors[2] == COLOR_CABLE or neighbors[2] == COLOR_CONNECTOR or neighbors[2] == COLOR_CABLE_VERTICAL) and (neighbors[3] == COLOR_CABLE or neighbors[3] == COLOR_CONNECTOR or neighbors[3] == COLOR_CABLE_VERTICAL)
					
					if horizontal:
						if vertical:
							cable.texture = [G.tex_cable_junction_1, G.tex_cable_junction_2].pick_random()
						elif neighbors[2] == COLOR_CABLE or neighbors[2] == COLOR_CONNECTOR or neighbors[2] == COLOR_CABLE_VERTICAL:
							cable.texture = G.tex_crossing_x_bottom
						elif neighbors[3] == COLOR_CABLE or neighbors[3] == COLOR_CONNECTOR or neighbors[3] == COLOR_CABLE_VERTICAL:
							cable.texture = G.tex_crossing_x_top
						else:
							cable.texture = G.tex_cable_h
					elif vertical:
						if neighbors[0] == COLOR_CABLE or neighbors[0] == COLOR_CONNECTOR or neighbors[0] == COLOR_CABLE_HORIZONTAL:
							cable.texture = G.tex_crossing_x_right
						elif neighbors[1] == COLOR_CABLE or neighbors[1] == COLOR_CONNECTOR or neighbors[1] == COLOR_CABLE_HORIZONTAL:
							cable.texture = G.tex_crossing_x_left
						else:
							cable.texture = G.tex_cable_v
					elif neighbors[0] == COLOR_CABLE or neighbors[0] == COLOR_CONNECTOR or neighbors[0] == COLOR_CABLE_HORIZONTAL:
						if neighbors[2] == COLOR_CABLE or neighbors[2] == COLOR_CONNECTOR or neighbors[2] == COLOR_CABLE_VERTICAL:
							cable.texture = G.tex_cable_corner_top_left
						elif neighbors[3] == COLOR_CABLE or neighbors[3] == COLOR_CONNECTOR or neighbors[3] == COLOR_CABLE_VERTICAL:
							cable.texture = G.tex_cable_corner_bottom_left
					elif neighbors[1] == COLOR_CABLE or neighbors[1] == COLOR_CONNECTOR or neighbors[1] == COLOR_CABLE_HORIZONTAL:
						if neighbors[2] == COLOR_CABLE or neighbors[2] == COLOR_CONNECTOR or neighbors[2] == COLOR_CABLE_VERTICAL:
							cable.texture = G.tex_cable_corner_top_right
						elif neighbors[3] == COLOR_CABLE or neighbors[3] == COLOR_CONNECTOR or neighbors[3] == COLOR_CABLE_VERTICAL:
							cable.texture = G.tex_cable_corner_bottom_right
					
				COLOR_CABLE_HORIZONTAL:					
					#print( "Position %d %d - Cable" %  [x, y] )
					var cable = create_cable_segment( x * sprite_width, y * sprite_height)
					num_nodes += 1
					
					cable.texture = G.tex_cable_h
				COLOR_CABLE_VERTICAL:					
					var cable = create_cable_segment( x * sprite_width, y * sprite_height)
					num_nodes += 1
					
					cable.texture = G.tex_cable_v
	
	var x_center = int(cable_segments_root.position.x * - (1.0 / num_nodes)) / 32 * 32.0
	var y_center = int(cable_segments_root.position.y * - (1.0 / num_nodes)) / 32 * 32.0
	
	cable_segments_root.position.x = x_center
	cable_segments_root.position.y = y_center

	#_generate_collision_shape()
