extends DebugEntryListEntry
class_name DebugEntryListPointEntry

@onready var _a_Type: TextureRect = get_node("HBox/VBox/Margin/Margin/HBox/Type")

var _a_point: Variant # Vector

func set_type_texture(p_texture: Texture2D) -> void:
	_a_Type.set_texture(p_texture)

func set_point(p_point: Variant) -> void:
	_a_point = p_point

func get_point() -> Variant:
	return _a_point

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Point"] = _a_point
	
	return data
