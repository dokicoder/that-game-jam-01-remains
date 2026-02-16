@tool
class_name GeneratedCable extends DraggableSnappable

@export_tool_button("Generate from Map", "Reload") var generate_action = _generate_cable_from_map

@export var cable_map: CableMap

var CableSegment: PackedScene = preload("uid://ddnm2l30qxrn7")
var Connector: PackedScene = preload("uid://chr8jbmvrtg1a")

const COLOR_CONNECTOR_FEMALE: Color = Color("#b43f2a")
const COLOR_CONNECTOR_MALE: Color = Color("#b4842a")
const COLOR_CABLE: Color = Color("#007b3a")
const COLOR_CABLE_HORIZONTAL: Color = Color("#00de0c")
const COLOR_CABLE_VERTICAL: Color = Color("003124")
const COLOR_BACKGROUND: Color = Color("#000000")

const sprite_width: float = 32
const sprite_height: float = 32

func update_owner(node: Node):
	if Engine.is_editor_hint():
		node.owner = get_tree().edited_scene_root

func get_map_pixel(x: int, y: int):
	if x < 0 or y < 0 or x >= cable_map.map_image.get_width() or y >= cable_map.map_image.get_height():
		return null
		
	return cable_map.map_image.get_pixel(x, y)
	
func get_neighbors(x: int, y: int):
	# [left, right, top, bottom]
	return {
		"left": get_map_pixel(x - 1, y), 
		"right": get_map_pixel(x + 1, y), 
		"top": get_map_pixel(x, y - 1), 
		"bottom": get_map_pixel(x, y + 1),
	}

const SOME_CABLE = [COLOR_CABLE, COLOR_CONNECTOR_FEMALE, COLOR_CONNECTOR_MALE]

func _generate_cable_from_map():
	_generate_cable_segments()
	_generate_collision_shape()
	# TODO: why needed two times?
	_generate_cable_segments()
	_generate_collision_shape()

func _generate_collision_shape():
	print("_generate_collision_shape")
	
	var cable_segments_root: Node2D = $CableSegmentsRoot;
	
	var area_2d: Area2D = $Area2D;

	# move Area2D to first position so hit shapes are in background
	self.move_child(area_2d, 0)

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

		collider.name = node.name + "_collider"

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
		
	var cable_segment: Node2D = CableSegment.instantiate()
	cable_segments_root.add_child(cable_segment)
	cable_segment.name = "Cable"
	cable_segment.position.x = position_x
	cable_segment.position.y = position_y
	
	cable_segments_root.position.x += position_x
	cable_segments_root.position.y += position_y

	update_owner(cable_segment)

	return cable_segment

static func matches(val, colors: Array) -> bool:
	return colors.has(val)

func _generate_cable_segments():
	print_debug("_generate_cable_from_map")
	
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

	var cable_dict = {}
	
	for node in cable_segments_root.get_children():
		node.queue_free()
	
	for x: int in cable_map.map_image.get_size().x:
		for y: int in cable_map.map_image.get_size().y:
			var pixel_color = cable_map.map_image.get_pixel(x, y)
			
			var neighbors = get_neighbors(x, y)
			
			var left_neighbor = neighbors["left"]
			var right_neighbor = neighbors["right"]
			var top_neighbor = neighbors["top"]
			var bottom_neighbor = neighbors["bottom"]
			
			var connector: Connector
	
			match pixel_color:
				COLOR_CONNECTOR_FEMALE, COLOR_CONNECTOR_MALE:
					#print( "Position %d %d - Connector" %  [x, y] )
					connector = Connector.instantiate()
					cable_segments_root.add_child(connector)
					connector.name = "Connector"
					cable_segments_root.move_child(connector, 0)
					num_nodes += 1
					
					if matches(left_neighbor, SOME_CABLE):
						connector.orientation = G.Orientation.RIGHT
					elif matches(right_neighbor, SOME_CABLE):
						connector.orientation = G.Orientation.LEFT
					elif matches(top_neighbor, SOME_CABLE):
						connector.orientation = G.Orientation.BOTTOM
					elif matches(bottom_neighbor, SOME_CABLE):
						connector.orientation = G.Orientation.TOP
						
					connector.position.x = x * sprite_width
					connector.position.y = y * sprite_height
				
					cable_segments_root.position.x += x * sprite_width
					cable_segments_root.position.y += y * sprite_height
						
					update_owner(connector)

					connector.other_intersection_entered.connect( _on_connectors_entered, ConnectFlags.CONNECT_PERSIST )
					connector.other_intersection_exited.connect( _on_connectors_exited, ConnectFlags.CONNECT_PERSIST )

					cable_dict["%d-%d" % [x, y]] = connector

					if x >= 0 && connector.orientation == G.Orientation.RIGHT:
						var left_neighbor_instance: CableSegment = cable_dict[("%d-%d" % [x-1, y])]
						
						left_neighbor_instance.adjacent_segments.push_back(connector)
						connector.adjacent_segments.push_back(left_neighbor_instance)
					if y >= 0 && connector.orientation == G.Orientation.BOTTOM:
						var top_neighbor_instance: CableSegment = cable_dict[("%d-%d" % [x, y-1])]
						
						top_neighbor_instance.adjacent_segments.push_back(connector)
						connector.adjacent_segments.push_back(top_neighbor_instance)
					
				COLOR_CABLE:
					#print( "Position %d %d - Cable" %  [x, y] )
					var cable_segment = create_cable_segment( x * sprite_width, y * sprite_height )
					num_nodes += 1
					
					var match_left = matches(left_neighbor, [COLOR_CABLE, COLOR_CONNECTOR_FEMALE, COLOR_CONNECTOR_MALE,  COLOR_CABLE_HORIZONTAL])
					var match_right = matches(right_neighbor, [COLOR_CABLE, COLOR_CONNECTOR_FEMALE, COLOR_CONNECTOR_MALE, COLOR_CABLE_HORIZONTAL])
					
					var match_top =  matches(top_neighbor, [COLOR_CABLE, COLOR_CONNECTOR_FEMALE, COLOR_CONNECTOR_MALE, COLOR_CABLE_VERTICAL])
					var match_bottom = matches(bottom_neighbor, [COLOR_CABLE, COLOR_CONNECTOR_FEMALE, COLOR_CONNECTOR_MALE, COLOR_CABLE_VERTICAL])
					
					var horizontal = match_left and match_right
					var vertical = match_top and match_bottom
					
					if match_left:
						var left_neighbor_instance: CableSegment = cable_dict[("%d-%d" % [x-1, y])]
						
						left_neighbor_instance.adjacent_segments.push_back(cable_segment)
						cable_segment.adjacent_segments.push_back(left_neighbor_instance)
						
					if match_top:
						var top_neighbor_instance: CableSegment = cable_dict[("%d-%d" % [x, y-1])]
						
						top_neighbor_instance.adjacent_segments.push_back(cable_segment)
						cable_segment.adjacent_segments.push_back(top_neighbor_instance)
					
					if horizontal:
						if vertical:
							# choose at random which cable goes on top
							# TODO: define actual 4-way crossing
							cable_segment.texture = [G.tex_cable_junction_1, G.tex_cable_junction_2].pick_random()
						elif match_top:
							cable_segment.texture = G.tex_crossing_x_bottom
						elif match_bottom:
							cable_segment.texture = G.tex_crossing_x_top
						else:
							cable_segment.texture = G.tex_cable_h
					elif vertical:
						if match_left:
							cable_segment.texture = G.tex_crossing_x_right
						elif match_right:
							cable_segment.texture = G.tex_crossing_x_left
						else:
							cable_segment.texture = G.tex_cable_v
					elif match_left:
						if match_top:
							cable_segment.texture = G.tex_cable_corner_top_left
						elif match_bottom:
							cable_segment.texture = G.tex_cable_corner_bottom_left
					elif match_right:
						if match_top:
							cable_segment.texture = G.tex_cable_corner_top_right
						elif match_bottom:
							cable_segment.texture = G.tex_cable_corner_bottom_right

					cable_dict["%d-%d" % [x, y]] = cable_segment
					
				COLOR_CABLE_HORIZONTAL:					
					#print( "Position %d %d - Cable" %  [x, y] )
					var cable_segment = create_cable_segment( x * sprite_width, y * sprite_height )
					num_nodes += 1
					
					cable_segment.texture = G.tex_cable_h

					if x >= 0:
						var left_neighbor_instance: CableSegment = cable_dict[("%d-%d" % [x-1, y])]
						
						left_neighbor_instance.adjacent_segments.push_back(cable_segment)
						cable_segment.adjacent_segments.push_back(left_neighbor_instance)

					cable_dict["%d-%d" % [x, y]] = cable_segment
					
				COLOR_CABLE_VERTICAL:					
					var cable_segment = create_cable_segment( x * sprite_width, y * sprite_height )
					num_nodes += 1
					
					cable_segment.texture = G.tex_cable_v

					if y >= 0:
						var top_neighbor_instance: CableSegment = cable_dict[("%d-%d" % [x, y-1])]
						
						top_neighbor_instance.adjacent_segments.push_back(cable_segment)
						cable_segment.adjacent_segments.push_back(top_neighbor_instance)
						
					cable_dict["%d-%d" % [x, y]] = cable_segment
			match pixel_color:
				COLOR_CONNECTOR_MALE:
					connector.with_contacts = true

	
	# TODO: is this calculation correct and the centering still needed?
	@warning_ignore("integer_division")
	var x_center = int(cable_segments_root.position.x * - (1.0 / num_nodes)) / 32 * 32.0
	@warning_ignore("integer_division")
	var y_center = int(cable_segments_root.position.y * - (1.0 / num_nodes)) / 32 * 32.0
	
	cable_segments_root.position.x = x_center
	cable_segments_root.position.y = y_center

	#_generate_collision_shape()
