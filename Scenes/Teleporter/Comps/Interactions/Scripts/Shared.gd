extends CompInteractionsShared
class_name TeleporterCompInteractionsShared

func interaction(p_area: Node) -> void:
	var dest: Array[StringName] = _a_entity_entity.get_destination()
	if dest.is_empty():
		super(p_area)
		return
	
	var scene_manager_si: Scene_Manager = Global.get_singleton(_a_entity, "Scene_Manager")
	scene_manager_si.change_scene_dest(dest)
	
	p_area.increase_interaction_count()
	interacted.emit()
