@tool
class_name ExampleToolUI extends MarginContainer

signal submit(text: String)

@onready var text_edit: TextEdit = $HBoxContainer/TextEdit
@onready var button: Button = $HBoxContainer/Button

func _on_button_pressed() -> void:
	submit.emit(text_edit.text)
