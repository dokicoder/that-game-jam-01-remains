class_name CableMap extends Resource
## Custom resource type holding an Image from which cables can be generated using a custom editor

@export var map_image: Image

func _init(image: Image = null):
	map_image = image
