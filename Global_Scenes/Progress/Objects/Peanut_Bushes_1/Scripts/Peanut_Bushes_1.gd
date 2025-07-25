extends "res://Global_Scenes/Progress/Objects/Scripts/Object_Base.gd"

var _a_pluck_count = 0

func increase_pluck_count():
	_a_pluck_count += 1

func set_pluck_count(p_pluck_count):
	_a_pluck_count = p_pluck_count

func get_pluck_count():
	return _a_pluck_count

func get_save_data():
	var data = {}
	data["Pluck_Count"] = _a_pluck_count
	
	return data

func load_file_data(p_data):
	_a_pluck_count = p_data["Pluck_Count"]
