extends Node2D

@onready var base_board: Node2D = $BaseBoard

func _ready() -> void:
	base_board.position.x = get_viewport().size.x * 0.5
	base_board.position.y = get_viewport().size.y * 0.5
