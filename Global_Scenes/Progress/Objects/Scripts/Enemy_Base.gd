extends ProgressObjectBase
class_name ProgressObjectEnemyBase

@onready var _a_Respawn_CD: Timer = get_node("Respawn_CD")

func start_respawn() -> void:
	_a_Respawn_CD.start()

func get_respawn_rdy() -> bool:
	return _a_Respawn_CD.is_stopped()

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Respawn_Rdy"] = _a_Respawn_CD.is_stopped()
	data[&"Respawn_CD"] = _a_Respawn_CD.get_time_left()
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	var respawn_rdy: bool = p_data[&"Respawn_Rdy"]
	if !respawn_rdy:
		_a_Respawn_CD.start(p_data[&"Respawn_CD"])
