extends Node
class_name FWTitleScreen

const _a_PROGRESS_SCENE_PATH: String = "res://Scenes/Title_Screen/Progress/Progress_%s.tscn"

var _a_save_file_idx: int = -1
var _a_progress: FWTitleScreenProgressBase

func _ready() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	global_si.reset()
	_update_progress_instance()

func _update_progress_instance() -> void:
	if _a_progress != null:
		_a_progress.queue_free()
	
	var progress_id: String = "None"
	_a_save_file_idx = Global_Data.get_save_file_idx()
	if _a_save_file_idx != -1:
		var auto_progress_id: String = _get_progress_id("Auto")
		if auto_progress_id.is_empty():
			var save_progress_id: String = _get_progress_id("Save")
			if !save_progress_id.is_empty():
				progress_id = save_progress_id
		else:
			progress_id = auto_progress_id
	
	var scene: PackedScene = load(_a_PROGRESS_SCENE_PATH % progress_id)
	_a_progress = scene.instantiate()
	_a_progress.request_progress_update.connect(_on_Progress_request_progress_update)
	add_child(_a_progress)

func _get_progress_id(p_key: String) -> String:
	var path: String = Global.get_save_path() % [_a_save_file_idx, p_key]
	if !FileAccess.file_exists(path):
		return ""
	var data: Dictionary = Data_Parser.load_var_data(path)
	return data[&"Singletons"][&"Progress"][&"Progress"][&"ID"]

func _on_Progress_request_progress_update() -> void:
	var save_file_idx: int = Global_Data.get_save_file_idx()
	if save_file_idx != _a_save_file_idx:
		_update_progress_instance()
