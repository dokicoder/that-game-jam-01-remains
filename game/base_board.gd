extends Node2D

@export var Socket: PackedScene
@export var GreenConnector: PackedScene
@export var RedConnector: PackedScene

@export_range(1, 20) var width: int = 10
@export_range(1, 20) var height: int = 10

@export var green_positions: Array[Vector2i] = []
@export var red_positions: Array[Vector2i] = []

@onready var center_node = $CenterNode; 

func _ready():
	# TODO: how to get size without instantiating?
	var reference_socket: Node2D = Socket.instantiate()
	
	var sprite_width = reference_socket.texture.get_width()
	var sprite_height = reference_socket.texture.get_height()
	
	center_node.position.x = - (width - 1) * sprite_width / 2.0
	center_node.position.y = - (height - 1) * sprite_height / 2.0
	
	reference_socket.queue_free()
	
	for x in range(width):
		for y in range(height):
			var socket: Node2D = Socket.instantiate()
			center_node.add_child(socket)
			socket.position.x = x * sprite_width
			socket.position.y = y * sprite_height
			
	for connector_position in green_positions:
		assert(connector_position.x < width)
		assert(connector_position.y < height)
		var connector: Node2D = GreenConnector.instantiate()
		center_node.add_child(connector)
		connector.position.x = connector_position.x * sprite_width
		connector.position.y = connector_position.y * sprite_height
	
	for connector_position in red_positions:
		assert(connector_position.x < width)
		assert(connector_position.y < height)
		var connector: Node2D = RedConnector.instantiate()
		center_node.add_child(connector)
		connector.position.x = connector_position.x * sprite_width
		connector.position.y = connector_position.y * sprite_height
