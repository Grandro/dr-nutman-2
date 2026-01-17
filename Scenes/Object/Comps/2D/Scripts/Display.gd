extends Sprite2D
class_name CompDisplay2D

var _a_Shared: GDScript = preload("res://Scenes/Object/Comps/Display/Scripts/Shared.gd")

var _a_shared: CompDisplayShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)

func init(_p_entity: Node) -> void:
	pass

func get_save_data() -> Dictionary:
	var data: Dictionary = _a_shared.get_save_data()
	var mat: Material = get_material()
	if mat != null:
		mat = mat.duplicate(true)
	data[&"Material"] = mat
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_shared.load_data(p_data)
	set_material(p_data[&"Material"])

func load_data_init() -> void:
	pass
