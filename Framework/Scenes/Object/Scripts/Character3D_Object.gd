extends CharacterBody3D
class_name FWCharacter3DObject

var _a_comph: FWCompHandler = FWCompHandler.new(self)

func _ready() -> void:
	_a_comph.register_comps()

func comph() -> FWCompHandler:
	return _a_comph

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Visible"] = is_visible()
	data[&"Transform"] = get_transform()
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_visible(p_data[&"Visible"])
	set_transform(p_data[&"Transform"])

func load_data_init() -> void:
	pass
