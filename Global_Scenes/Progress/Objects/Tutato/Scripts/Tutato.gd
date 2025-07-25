extends "res://Global_Scenes/Progress/Objects/Scripts/Object_Base.gd"

var _a_explain_battle_attack = true
var _a_explain_battle_dodge = true
var _a_explain_inventory = true
var _a_explain_journal = true
var _a_explain_party = true
var _a_explain_quests = true
var _a_explain_options = true
var _a_explain_on_map_encounter = true

func set_explain_battle_attack(p_explain_battle_attack):
	_a_explain_battle_attack = p_explain_battle_attack

func get_explain_battle_attack():
	return _a_explain_battle_attack

func set_explain_battle_dodge(p_explain_battle_dodge):
	_a_explain_battle_dodge = p_explain_battle_dodge

func get_explain_battle_dodge():
	return _a_explain_battle_dodge

func set_explain_inventory(p_explain_inventory):
	_a_explain_inventory = p_explain_inventory

func get_explain_inventory():
	return _a_explain_inventory

func set_explain_journal(p_explain_journal):
	_a_explain_journal = p_explain_journal

func get_explain_journal():
	return _a_explain_journal

func set_explain_party(p_explain_party):
	_a_explain_party = p_explain_party

func get_explain_party():
	return _a_explain_party

func set_explain_quests(p_explain_quests):
	_a_explain_quests = p_explain_quests

func get_explain_quests():
	return _a_explain_quests

func set_explain_options(p_explain_options):
	_a_explain_options = p_explain_options

func get_explain_options():
	return _a_explain_options

func set_explain_on_map_encounter(p_explain_on_map_encounter):
	_a_explain_on_map_encounter = p_explain_on_map_encounter

func get_explain_on_map_encounter():
	return _a_explain_on_map_encounter

func get_save_data():
	var data = {}
	data["Explain_Battle_Attack"] = _a_explain_battle_attack
	data["Explain_Battle_Dodge"] = _a_explain_battle_dodge
	data["Explain_Inventory"] = _a_explain_inventory
	data["Explain_Journal"] = _a_explain_journal
	data["Explain_Party"] = _a_explain_party
	data["Explain_Quests"] = _a_explain_quests
	data["Explain_Options"] = _a_explain_options
	data["Explain_On_Map_Encounter"] = _a_explain_on_map_encounter
	
	return data

func load_file_data(p_data):
	_a_explain_battle_attack = p_data["Explain_Battle_Attack"]
	_a_explain_battle_dodge = p_data["Explain_Battle_Dodge"]
	_a_explain_inventory = p_data["Explain_Inventory"]
	_a_explain_journal = p_data["Explain_Journal"]
	_a_explain_party = p_data["Explain_Party"]
	_a_explain_quests = p_data["Explain_Quests"]
	_a_explain_options = p_data["Explain_Options"]
	_a_explain_on_map_encounter = p_data["Explain_On_Map_Encounter"]
