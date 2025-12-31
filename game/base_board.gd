extends Node2D

@export var SocketScene: PackedScene

@export_range(1, 20) var width: int = 10
@export_range(1, 20) var height: int = 10

@onready var center_node = $CenterNode; 

func _ready():
	# TODO: how to get size without instantiating?
	var reference_socket: Sprite2D = SocketScene.instantiate()
	
	var sprite_width = reference_socket.texture.get_width()
	var sprite_height = reference_socket.texture.get_height()
	
	center_node.position.x = - (width - 1) * sprite_width / 2.0
	center_node.position.y = - (height - 1) * sprite_height / 2.0
	
	reference_socket.queue_free()
	
	for x in range(width):
		for y in range(height):
			var socket: Sprite2D = SocketScene.instantiate()
			center_node.add_child(socket)
			socket.position.x = x * sprite_width
			socket.position.y = y * sprite_height
