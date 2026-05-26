extends FWProgressObjectBase
class_name ProgressObjectPeanutBushes1

var _a_pluck_count: int = 0

func increase_pluck_count() -> void:
	_a_pluck_count += 1

func set_pluck_count(p_pluck_count: int) -> void:
	_a_pluck_count = p_pluck_count

func get_pluck_count() -> int:
	return _a_pluck_count

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Pluck_Count"] = _a_pluck_count
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	_a_pluck_count = p_data[&"Pluck_Count"]
