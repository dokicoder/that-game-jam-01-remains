@tool
class_name ExampleTool extends EditorScript 

var window: Window

var gui: Resource = preload("res://tools/ExampleToolScene.tscn")

func _run():	
	var gui_scene: ExampleToolUI = gui.instantiate()
	
	window = Window.new()
	
	window.add_child(gui_scene)
	
	gui_scene.submit.connect(_on_confirmed)
	
	EditorInterface.popup_dialog(window, Rect2i(100, 1200, 800, 600))
	
	
	window.close_requested.connect(
		func():
			window.queue_free()
	)

func _on_confirmed(val: String):
	print("Val was:")
	print(val)
	
