extends ProgressObjectBase
class_name ProgressObjectTutato

var _a_explain_battle_attack: bool = true
var _a_explain_battle_dodge: bool = true
var _a_explain_inventory: bool = true
var _a_explain_journal: bool = true
var _a_explain_party: bool = true
var _a_explain_quests: bool = true
var _a_explain_options: bool = true
var _a_explain_on_map_encounter: bool = true

func set_explain_battle_attack(p_explain_battle_attack: bool) -> void:
	_a_explain_battle_attack = p_explain_battle_attack

func get_explain_battle_attack() -> bool:
	return _a_explain_battle_attack

func set_explain_battle_dodge(p_explain_battle_dodge: bool) -> void:
	_a_explain_battle_dodge = p_explain_battle_dodge

func get_explain_battle_dodge() -> bool:
	return _a_explain_battle_dodge

func set_explain_inventory(p_explain_inventory: bool) -> void:
	_a_explain_inventory = p_explain_inventory

func get_explain_inventory() -> bool:
	return _a_explain_inventory

func set_explain_journal(p_explain_journal: bool) -> void:
	_a_explain_journal = p_explain_journal

func get_explain_journal() -> bool:
	return _a_explain_journal

func set_explain_party(p_explain_party: bool) -> void:
	_a_explain_party = p_explain_party

func get_explain_party() -> bool:
	return _a_explain_party

func set_explain_quests(p_explain_quests: bool) -> void:
	_a_explain_quests = p_explain_quests

func get_explain_quests() -> bool:
	return _a_explain_quests

func set_explain_options(p_explain_options: bool) -> void:
	_a_explain_options = p_explain_options

func get_explain_options() -> bool:
	return _a_explain_options

func set_explain_on_map_encounter(p_explain_on_map_encounter: bool) -> void:
	_a_explain_on_map_encounter = p_explain_on_map_encounter

func get_explain_on_map_encounter() -> bool:
	return _a_explain_on_map_encounter

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Explain_Battle_Attack"] = _a_explain_battle_attack
	data[&"Explain_Battle_Dodge"] = _a_explain_battle_dodge
	data[&"Explain_Inventory"] = _a_explain_inventory
	data[&"Explain_Journal"] = _a_explain_journal
	data[&"Explain_Party"] = _a_explain_party
	data[&"Explain_Quests"] = _a_explain_quests
	data[&"Explain_Options"] = _a_explain_options
	data[&"Explain_On_Map_Encounter"] = _a_explain_on_map_encounter
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	_a_explain_battle_attack = p_data[&"Explain_Battle_Attack"]
	_a_explain_battle_dodge = p_data[&"Explain_Battle_Dodge"]
	_a_explain_inventory = p_data[&"Explain_Inventory"]
	_a_explain_journal = p_data[&"Explain_Journal"]
	_a_explain_party = p_data[&"Explain_Party"]
	_a_explain_quests = p_data[&"Explain_Quests"]
	_a_explain_options = p_data[&"Explain_Options"]
	_a_explain_on_map_encounter = p_data[&"Explain_On_Map_Encounter"]
