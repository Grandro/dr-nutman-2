extends Control
class_name SceneManagerLoadingScreen

@onready var _a_Progress: ProgressBar = get_node("Center/VBox/Progress")

func _on_Scene_Loader_progress_changed(p_progress: float) -> void:
	_a_Progress.set_value(p_progress * 100.0)
