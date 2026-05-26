extends FWExtensionBase
class_name FWCompListenerShared

func init(p_entities: Array[Node]) -> void:
	var entity_entity_comph: FWCompHandler = p_entities[-1].comph()
	var camera_comp: Node = entity_entity_comph.get_comp("Camera")
	camera_comp.made_current.connect(_on_Camera_made_current)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Curr"] = _a_entity.is_current()
	
	return data

func load_data(p_data: Dictionary) -> void:
	if p_data[&"Curr"]:
		_a_entity.make_current()

func _on_Camera_made_current() -> void:
	_a_entity.make_current()
