extends NavigationObstacle3D
class_name CompNavObstacle3D

var _a_Shared: GDScript = preload("res://Scenes/Object/Comps/Nav_Obstacle/Scripts/Shared.gd")

var _a_shared: CompNavObstacleShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.ready()

func init(_p_entity: Node) -> void:
	pass

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
