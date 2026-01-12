@tool
extends Node2D

@export var Socket: PackedScene
@export var GreenConnector: PackedScene
@export var RedConnector: PackedScene

@export_range(1, 100) var width: int:
	get:
		return _width
	set(value):
		_width = value
		if Engine.is_editor_hint():
			update_board()

@export_range(1, 100) var height: int:
	get:
		return _height
	set(value):
		_height = value
		if Engine.is_editor_hint():
			update_board()

@export var green_positions: Array[Vector2i] = []
@export var red_positions: Array[Vector2i] = []

@export_tool_button("Refresh", "Reload") var refresh_action = refresh

func refresh():
	update_board()

var _green_positions: Array[Vector2i] = []
var _red_positions: Array[Vector2i] = []

var _width: int = 10
var _height: int = 10

func _ready():
	update_board()
	
func update_board():
	print_debug("update_board")
	
	var center_node: Node2D = $CenterNode;
	
	for node in center_node.get_children():
		node.queue_free()
		
	# TODO: how to get size without instantiating?
	var reference_socket: Node2D = Socket.instantiate()
	
	var sprite_width = reference_socket.texture.get_width()
	var sprite_height = reference_socket.texture.get_height()
	
	center_node.position.x = - (width / 2) * sprite_width
	center_node.position.y = - (height / 2) * sprite_height
	
	reference_socket.queue_free()
	
	for x in range(width):
		for y in range(height):
			var socket: Node2D = Socket.instantiate()
			center_node.add_child(socket)
			socket.position.x = x * sprite_width
			socket.position.y = y * sprite_height

			socket.owner = get_tree().edited_scene_root

	var green_positions_copy = green_positions.duplicate(false)
	green_positions_copy.sort_custom(func(a, b): 
		if a.x == b.x:
			return a.y <= b.y
		return a.x <= b.x
	)
	green_positions = green_positions_copy

	var red_positions_copy = red_positions.duplicate(false)
	red_positions_copy.sort_custom(func(a, b): 
		if a.x == b.x:
			return a.y <= b.y
		return a.x <= b.x
	)
	red_positions = red_positions_copy
			
	for connector_position in green_positions:
		assert(connector_position.x < _width)
		assert(connector_position.y < _height)
		var connector: Node2D = GreenConnector.instantiate()
		center_node.add_child(connector)
		connector.position.x = connector_position.x * sprite_width
		connector.position.y = connector_position.y * sprite_height

		connector.owner = get_tree().edited_scene_root
	
	for connector_position in red_positions:
		assert(connector_position.x < _width)
		assert(connector_position.y < _height)
		var connector: Node2D = RedConnector.instantiate()
		center_node.add_child(connector)
		connector.position.x = connector_position.x * sprite_width
		connector.position.y = connector_position.y * sprite_height

		connector.owner = get_tree().edited_scene_root
	
