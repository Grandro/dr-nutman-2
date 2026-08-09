extends Node3D
class_name SVEncounterPlacePos

func get_place_pos(p_amount: int) -> Array[Vector3]:
	var place_pos: Array[Vector3] = []
	var parent: Node3D = get_child(p_amount - 1)
	var size: int = parent.get_child_count()
	place_pos.resize(size)
	for i: int in size:
		var child: Node3D = parent.get_child(i)
		var pos: Vector3 = child.get_position()
		place_pos[i] = pos
	
	return place_pos
