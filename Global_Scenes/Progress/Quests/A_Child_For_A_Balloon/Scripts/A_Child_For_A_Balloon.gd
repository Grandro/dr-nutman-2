extends ProgressQuestBase
class_name ProgressQuestAChildForABalloon

const _a_KEYS: Array[StringName] = [&"Buffin_Child_1", &"Buffin_Child_2", &"Buffin_Child_3",
									&"Buffin_Child_4", &"Broko_Child_1", &"Broko_Child_2",
									&"Broko_Child_3"]

var _a_progress: Dictionary = {}

func _ready() -> void:
	for key: StringName in _a_KEYS:
		_a_progress[key] = {}
		_a_progress[key][&"Child_Ask"] = false
		_a_progress[key][&"Child_Asked"] = false
		_a_progress[key][&"Player_Got_Balloon"] = false

func set_child_ask(p_key: StringName, p_child_ask: bool) -> void:
	_a_progress[p_key][&"Child_Ask"] = p_child_ask

func get_child_ask(p_key: StringName) -> bool:
	return _a_progress[p_key][&"Child_Ask"]

func set_child_asked(p_key: StringName, p_child_asked: bool) -> void:
	_a_progress[p_key][&"Child_Asked"] = p_child_asked

func get_child_asked(p_key: StringName) -> bool:
	return _a_progress[p_key][&"Child_Asked"]

func set_player_got_balloon(p_key: StringName, p_player_got_balloon: bool) -> void:
	_a_progress[p_key][&"Player_Got_Balloon"] = p_player_got_balloon

func get_player_got_balloon(p_key: StringName) -> bool:
	return _a_progress[p_key][&"Player_Got_Balloon"]

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Progress"] = _a_progress
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_progress = p_data[&"Progress"]
