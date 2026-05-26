extends AudioListener3D
class_name FWCompListener3D

var _a_Shared: GDScript = preload("uid://dgs0nwu6rxmj")

var _a_shared: FWCompListenerShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)

func init(p_entities: Array[Node]) -> void:
	_a_shared.init(p_entities)

func get_save_data() -> Dictionary:
	return _a_shared.get_save_data()

func load_data(p_data: Dictionary) -> void:
	_a_shared.load_data(p_data)

func load_data_init() -> void:
	pass
