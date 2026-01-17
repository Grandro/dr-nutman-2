extends AudioListener3D
class_name CompListener3D

var _a_Shared: GDScript = preload("res://Scenes/Object/Comps/Listener/Scripts/Shared.gd")

var _a_shared: CompListenerShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)

func init(p_entity) -> void:
	_a_shared.init(p_entity)

func get_save_data() -> Dictionary:
	return _a_shared.get_save_data()

func load_data(p_data: Dictionary) -> void:
	_a_shared.load_data(p_data)

func load_data_init() -> void:
	pass
