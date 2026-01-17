extends CollisionPolygon3D
class_name CompCollisionPolygon3D

var _a_Shared: GDScript = preload("res://Scenes/Object/Comps/Collision/Scripts/Shared.gd")

var _a_shared: CompCollisionShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)

func init(p_entity: Node) -> void:
	_a_shared.init(p_entity)

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
