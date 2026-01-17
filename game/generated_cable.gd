@tool
class_name GeneratedCable extends DraggableCable

var CableSegment: PackedScene = preload("res://game/CableSegment.tscn")
var Extension: PackedScene = preload("res://game/Extension.tscn")

@export_tool_button("Generate from Map", "Reload") var generate_action = _generate_cable_from_map

const COLOR_CONNECTOR: Color = Color("#b43f2a")
const COLOR_CABLE: Color = Color("#007b3a")
const COLOR_BACKGROUND: Color = Color("#000000")

func get_map_pixel(x: int, y: int):
	if x < 0 or y < 0 or x >= cable_map.map_image.get_width() or y >= cable_map.map_image.get_height():
		return null
		
	return cable_map.map_image.get_pixel(x, y)
	
func get_neighbors(x: int, y: int):
	# [left, right, top, bottom]
	return [get_map_pixel(x - 1, y), get_map_pixel(x + 1, y), get_map_pixel(x, y - 1), get_map_pixel(x, y + 1)]

func _generate_cable_from_map():
	print("generate")
	
	if not is_instance_valid(cable_map) or not is_instance_valid(cable_map.map_image):
		print("no cable map to generate from, skipping")
		return
	
	# TODO: how to get size without instantiating?
	var reference_socket: Node2D = CableSegment.instantiate()
	
	var sprite_width = reference_socket.texture.get_width()
	var sprite_height = reference_socket.texture.get_height()

	var num_nodes: int = 0
	
	var cable_segments_root: Node2D = $CableSegmentsRoot;

	if not is_instance_valid(cable_segments_root):
		cable_segments_root = Node2D.new()
		cable_segments_root.name = "CableSegmentsRoot"
		self.add_child(cable_segments_root)
		cable_segments_root.owner = get_tree().edited_scene_root
	
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
						
					extension.owner = get_tree().edited_scene_root

					extension.other_intersection_entered.connect(_on_extensions_entered, ConnectFlags.CONNECT_PERSIST )
					extension.other_intersection_exited.connect(_on_extensions_exited, ConnectFlags.CONNECT_PERSIST )
					
					num_nodes += 1
				COLOR_CABLE:
					#print( "Position %d %d - Cable" %  [x, y] )
					var cable: Sprite2D = CableSegment.instantiate()
					cable_segments_root.add_child(cable)
					cable.position.x = x * sprite_width
					cable.position.y = y * sprite_height
					
					cable_segments_root.position.x += x * sprite_width
					cable_segments_root.position.y += y * sprite_height
					
					var horizontal = (neighbors[0] == COLOR_CABLE or neighbors[0] == COLOR_CONNECTOR) and (neighbors[1] == COLOR_CABLE or neighbors[1] == COLOR_CONNECTOR)
					var vertical = (neighbors[2] == COLOR_CABLE or neighbors[2] == COLOR_CONNECTOR) and (neighbors[3] == COLOR_CABLE or neighbors[3] == COLOR_CONNECTOR)
					
					if horizontal:
						if vertical:
							cable.texture = [G.tex_cable_junction_1, G.tex_cable_junction_2].pick_random()
						elif neighbors[2] == COLOR_CABLE or neighbors[2] == COLOR_CONNECTOR:
							cable.texture = G.tex_crossing_x_bottom
						elif neighbors[3] == COLOR_CABLE or neighbors[3] == COLOR_CONNECTOR:
							cable.texture = G.tex_crossing_x_top
						else:
							cable.texture = G.tex_cable_h
					elif vertical:
						if neighbors[0] == COLOR_CABLE or neighbors[0] == COLOR_CONNECTOR:
							cable.texture = G.tex_crossing_x_right
						elif neighbors[1] == COLOR_CABLE or neighbors[1] == COLOR_CONNECTOR:
							cable.texture = G.tex_crossing_x_left
						else:
							cable.texture = G.tex_cable_v
					elif neighbors[0] == COLOR_CABLE or neighbors[0] == COLOR_CONNECTOR:
						if neighbors[2] == COLOR_CABLE or neighbors[2] == COLOR_CONNECTOR:
							cable.texture = G.tex_cable_corner_top_left
						elif neighbors[3] == COLOR_CABLE or neighbors[3] == COLOR_CONNECTOR:
							cable.texture = G.tex_cable_corner_bottom_left
					elif neighbors[1] == COLOR_CABLE or neighbors[1] == COLOR_CONNECTOR:
						if neighbors[2] == COLOR_CABLE or neighbors[2] == COLOR_CONNECTOR:
							cable.texture = G.tex_cable_corner_top_right
						elif neighbors[3] == COLOR_CABLE or neighbors[3] == COLOR_CONNECTOR:
							cable.texture = G.tex_cable_corner_bottom_right
					
					cable.owner = get_tree().edited_scene_root
					
					num_nodes += 1
	
	var x_center = int(cable_segments_root.position.x * - (1.0 / num_nodes)) / 32 * 32.0
	var y_center = int(cable_segments_root.position.y * - (1.0 / num_nodes)) / 32 * 32.0
	
	cable_segments_root.position.x = x_center
	cable_segments_root.position.y = y_center
