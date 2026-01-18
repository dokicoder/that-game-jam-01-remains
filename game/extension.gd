@tool
class_name Extension extends Area2D

signal other_intersection_entered(this: Extension, other: Extension)
signal other_intersection_exited(this: Extension, other: Extension)

@export var orientation: G.Orientation:
	get: return _orientation
	set(value): 
		_orientation = value
		if not Engine.is_editor_hint():
			return
		update_orientation()
		
@export var with_contacts: bool:
	get: return _with_contacts
	set(value):
		_with_contacts = value
		if not Engine.is_editor_hint():
			return
		$Root/Contacts.visible = value

var connected_extension: Extension = null

var _orientation: G.Orientation = G.Orientation.LEFT
var _with_contacts: bool = false

func generate_collision_polygon(pass_transform: Transform2D):
	var image = $Cable.texture.get_image()

	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	bitmap.grow_mask(2, Rect2(Vector2(0, 0), bitmap.get_size()))
	
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()), 3)

	for polygon in polygons:
			if Geometry2D.is_polygon_clockwise(polygon):
				#print("=> Clockwise")
				
				polygon = Transform2D(0, Vector2(-16.0, -16.0)) * polygon
				
				var collider = CollisionPolygon2D.new()
				collider.polygon = polygon
			
				add_child(collider)
				
				collider.owner = get_tree().edited_scene_root
				
				return pass_transform * polygon
				#print(": Counterclockwise")
	return null

# hide contacts without changin visible, used e.g. for snapping
func hide_contacts():
	$Root/Contacts.visible = false
	
func restore_contacts():
	$Root/Contacts.visible = _with_contacts

func _ready():
	# TODO: why is this needed?
	update_orientation()
	#print_debug("init with contatcs ", _with_contacts)
	$Root/Contacts.visible = _with_contacts

func update_orientation():
	#print_debug("update_orientation")

	match _orientation:
		G.Orientation.LEFT:
			$Cable.texture = G.tex_cable_right
		G.Orientation.RIGHT:
			$Cable.texture = G.tex_cable_left
		G.Orientation.TOP:
			$Cable.texture = G.tex_cable_bottom
		G.Orientation.BOTTOM:
			$Cable.texture = G.tex_cable_top
			
	match _orientation:
		G.Orientation.RIGHT, G.Orientation.BOTTOM:
			$Root/Cover.texture = G.tex_cover_left
			$Root/Contacts.texture = G.tex_contacts_right
			$Root/Cover.rotation = 0
		G.Orientation.LEFT, G.Orientation.TOP:
			$Root/Cover.texture = G.tex_cover_right
			$Root/Contacts.texture = G.tex_contacts_left
			
	match _orientation:
		G.Orientation.TOP, G.Orientation.BOTTOM:
			$Root.rotation = PI * 0.5
		G.Orientation.LEFT, G.Orientation.RIGHT:
			$Root.rotation = 0

func _on_area_entered(other: Extension) -> void:
	other_intersection_entered.emit(self, other as Extension)

func _on_area_exited(other: Extension) -> void:
	other_intersection_exited.emit(self, other as Extension)
