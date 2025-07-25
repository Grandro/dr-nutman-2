extends "res://Global_Scenes/Progress/Quests/Scripts/Quest_Base.gd"

const _a_KEYS = ["Buffin_Child_1", "Buffin_Child_2", "Buffin_Child_3",
				 "Buffin_Child_4", "Broko_Child_1", "Broko_Child_2",
				 "Broko_Child_3"]

var _a_progress = {}

func _ready():
	for key in _a_KEYS:
		_a_progress[key] = {}
		_a_progress[key]["Child_Ask"] = false
		_a_progress[key]["Child_Asked"] = false
		_a_progress[key]["Player_Got_Balloon"] = false

func set_child_ask(p_key, p_child_ask):
	_a_progress[p_key]["Child_Ask"] = p_child_ask

func get_child_ask(p_key):
	return _a_progress[p_key]["Child_Ask"]

func set_child_asked(p_key, p_child_asked):
	_a_progress[p_key]["Child_Asked"] = p_child_asked

func get_child_asked(p_key):
	return _a_progress[p_key]["Child_Asked"]

func set_player_got_balloon(p_key, p_player_got_balloon):
	_a_progress[p_key]["Player_Got_Balloon"] = p_player_got_balloon

func get_player_got_balloon(p_key):
	return _a_progress[p_key]["Player_Got_Balloon"]

func get_save_data():
	var data = super()
	data["Progress"] = _a_progress
	
	return data

func load_file_data(p_data):
	super(p_data)
	_a_progress = p_data["Progress"]
