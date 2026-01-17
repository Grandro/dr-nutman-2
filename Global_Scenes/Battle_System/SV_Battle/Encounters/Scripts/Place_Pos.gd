extends Node3D
class_name SVEncounterPlacePos

func get_place_pos(p_amount: int) -> Array[Vector3]:
	var place_pos: Array[Vector3] = []
	var parent: Node3D = get_child(p_amount - 1)
	for child: Node3D in parent.get_children():
		var pos: Vector3 = child.get_position()
		place_pos.append(pos)
	
	return place_pos
