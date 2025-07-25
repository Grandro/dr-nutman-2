extends "res://Scenes/Maps/3D/Broko_Town/Broko_Town_1/Objects/Comps/Balloons/Scripts/Balloons_Base.gd"

func init(p_entity):
	super(p_entity)
	for child in _a_Containers.get_children():
		var key = child.get_name()
		_a_containers[key] = child
	
	if _a_containers.is_empty():
		set_process(false)
