extends AnimatedSprite2D

@export var spawn_parent: Node2D 

@export var base_path: String 

var GeneratedCable: PackedScene = preload("uid://dchuo6eveswkk")

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			play("press")
			dispense_cable()

func _on_area_2d_mouse_entered() -> void:
	self_modulate = Color(1.7, 1.3, 0.0)

func _on_area_2d_mouse_exited() -> void:
	self_modulate = Color(1.0, 1.0, 1.0)

func dispense_cable():
	var generated_cable: GeneratedCable = GeneratedCable.instantiate()	
	var cable_types_folder = DirAccess.open(base_path)
	
	if cable_types_folder == null: printerr("Could not open folder"); return

	generated_cable.cable_map = load(base_path + "/" + Array(cable_types_folder.get_files()).pick_random())
	generated_cable._generate_cable_from_map()
	
	spawn_parent.add_child(generated_cable)

	generated_cable.global_position = $TargetPosition.global_position

	
	
