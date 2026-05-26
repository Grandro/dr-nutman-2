extends Node3D
class_name CompDebug3D

@onready var _a_Reference_Key: Label3D = get_node("Reference_Key")

func _ready() -> void:
	if !OS.is_debug_build():
		queue_free()

func init(p_entities: Array[Node]) -> void:
	var entity_comph: FWCompHandler = p_entities[-1].comph()
	if entity_comph.has_comp("Reference"):
		var key: StringName = entity_comph.call_comp("Reference", &"get_key")
		_a_Reference_Key.set_text("Key: %s" % key)

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
