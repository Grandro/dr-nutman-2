extends NavigationObstacle3D
class_name FWCompNavObstacle3D

var _a_Shared: GDScript = preload("uid://t3nncl5eloa3")

var _a_shared: FWCompNavObstacleShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.ready()

func init(_p_entities: Array[Node]) -> void:
	pass

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
