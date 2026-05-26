extends CollisionPolygon3D
class_name FWCompCollisionPolygon3D

var _a_Shared: GDScript = preload("uid://b4sbxeayjusrm")

var _a_shared: FWCompCollisionShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)

func init(p_entities: Array[Node]) -> void:
	_a_shared.init(p_entities)

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
