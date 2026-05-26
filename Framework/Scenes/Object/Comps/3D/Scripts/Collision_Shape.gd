extends CollisionShape3D
class_name FWCompCollisionShape3D

var _a_Shared: GDScript = preload("uid://b4sbxeayjusrm")

var _a_shared: FWCompCollisionShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)

func init(p_entities: Array[Node]) -> void:
	_a_shared.init(p_entities)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Transform"] = get_transform()
	data[&"Shape"] = Data_Parser.parse_object(shape)
	data[&"Disabled"] = is_disabled()
	
	return data

func load_data(p_data: Dictionary) -> void:
	var shape_: Shape3D = Data_Parser.unparse_object(p_data[&"Shape"])
	set_transform(p_data[&"Transform"])
	set_shape(shape_)
	set_disabled(p_data[&"Disabled"])

func load_data_init() -> void:
	pass
