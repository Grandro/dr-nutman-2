extends Node
class_name CompCutscene

var _a_in_cutscene: int = 0 # 0: not in cutscene, >0: in cutscene
var _a_disabled_by_cutscene: int = 0 # 0: not disabled, >0: disabled

func init(_p_entity: Node) -> void:
	pass

func increase_in_cutscene() -> void:
	set_in_cutscene(_a_in_cutscene + 1)

func decrease_in_cutscene() -> void:
	set_in_cutscene(_a_in_cutscene - 1)

func increase_disabled_by_cutscene() -> void:
	set_disabled_by_cutscene(_a_disabled_by_cutscene + 1)

func decrease_disabled_by_cutscene() -> void:
	set_disabled_by_cutscene(_a_disabled_by_cutscene - 1)

func set_in_cutscene(p_in_cutscene: int) -> void:
	_a_in_cutscene = p_in_cutscene

func set_disabled_by_cutscene(p_disabled: int) -> void:
	_a_disabled_by_cutscene = p_disabled

func is_in_cutscene() -> bool:
	return _a_in_cutscene > 0

func is_disabled_by_cutscene() -> bool:
	return _a_disabled_by_cutscene > 0

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Disabled_By_Cutscene"] = _a_disabled_by_cutscene
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_disabled_by_cutscene(p_data[&"Disabled_By_Cutscene"])

func load_data_init() -> void:
	pass
