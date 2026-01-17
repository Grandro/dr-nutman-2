extends ProgressObjectBase
class_name ProgressObjectNPCBase

var _a_location: StringName
var _a_dest: StringName = &""

func _ready() -> void:
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	_a_location = scene_manager_si.get_location()

func set_location(p_location: StringName) -> void:
	_a_location = p_location

func get_location() -> StringName:
	return _a_location

func set_dest(p_dest: StringName) -> void:
	_a_dest = p_dest

func get_dest() -> StringName:
	return _a_dest

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Location"] = _a_location
	data[&"Dest"] = _a_dest
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_location = p_data[&"Location"]
	_a_dest = p_data[&"Dest"]
