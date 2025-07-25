extends "res://Scenes/Object/Comps/Interactions/Scripts/Shared.gd"

var _a_destinations: Array = [] # (Array, Array, String)

func interaction(p_area):
	if _a_destinations.is_empty():
		return
	
	if p_area == _a_Default_Interaction:
		var scene_manager_si = Global.get_singleton(_a_entity, "Scene_Manager")
		scene_manager_si.change_scene_dest(_a_destinations[0])

func set_destinations(p_destinations):
	_a_destinations = p_destinations
