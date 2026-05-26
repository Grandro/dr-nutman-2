extends FWCompInteractionsShared
class_name ObjectBuildingBaseCompInteractionsShared

var _a_destinations: Array = [] # (Array, Array, String)

func interaction(p_area: Node) -> void:
	if _a_destinations.is_empty():
		return
	
	if p_area == _a_Default_Interaction:
		var scene_manager_si: Scene_Manager = Global.get_singleton(_a_entity, "Scene_Manager")
		var dest: Array[StringName]; dest.assign(_a_destinations[0])
		scene_manager_si.change_scene_dest(dest)

func set_destinations(p_destinations: Array) -> void:
	_a_destinations = p_destinations
