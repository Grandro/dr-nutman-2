extends Node
class_name TitleScreen

const _a_PROGRESS_SCENE_PATH: String = "res://Scenes/Title_Screen/Progress/Progress_%s.tscn"

func _ready() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	global_si.reset()
	
	var progress_id: String = "None"
	var save_file_idx: int = Global_Data.get_save_file_idx()
	if save_file_idx != -1:
		var path: String = Global.get_save_path() % str(save_file_idx)
		var data: Dictionary = Data_Parser.load_var_data(path)
		progress_id = data[&"Singletons"][&"Progress"][&"Progress"][&"ID"]
	
	var scene: PackedScene = load(_a_PROGRESS_SCENE_PATH % progress_id)
	var instance: TitleScreenProgressBase = scene.instantiate()
	add_child(instance)
