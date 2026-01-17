extends Node
class_name NodeObject

var _a_comph: CompHandler = CompHandler.new(self)

func _ready() -> void:
	_a_comph.register_comps()

func comph() -> CompHandler:
	return _a_comph

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
