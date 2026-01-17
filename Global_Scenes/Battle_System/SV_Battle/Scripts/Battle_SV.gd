extends Node
class_name BattleSV

signal battle_ended(p_location: StringName, p_res: StringName)

enum MAP_RES {PARTY_MEMBER, ENEMY, NEUTRAL}

@onready var _a_Result: SVResult = get_node("Result")

var _a_return_map: PackedScene # Used to keep map in cache
var _a_return_location: StringName # Location to return to after battle
var _a_res: StringName # Win/Loss

func _ready() -> void:
	_a_Result.closed.connect(_on_Result_closed)

func battle(p_enc_key: StringName, p_map_res: MAP_RES, p_troop: Array[StringName] = []) -> void:
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	_a_return_map = scene_manager_si.get_curr_scene()
	_a_return_location = scene_manager_si.get_location()
	
	var data: SVEncounterData = Databases.get_data_entry(&"SV_Encounters", p_enc_key)
	var path: String = data.get_path_()
	var special: bool = data.get_special()
	var cb: Callable = _CB_Scene_Manager_Encounter_Set.bind(p_map_res, p_troop, special)
	scene_manager_si.change_scene_path(path, cb)

func _tp_to_return_location() -> void:
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	var cb_method: Callable = _CB_Scene_Manager_Return_Scene_Set.bind(_a_return_location, _a_res)
	scene_manager_si.change_scene_tp(_a_return_location, cb_method)

func _CB_Scene_Manager_Encounter_Set(p_instance: SVEncounterBase, p_map_res: MAP_RES, p_troop: Array[StringName], p_special: bool) -> void:
	p_instance.battle_ended.connect(_on_Encounter_battle_ended)
	p_instance.set_map_res(p_map_res)
	p_instance.set_troop(p_troop)
	p_instance.set_special(p_special)
	p_instance.battle()

func _CB_Scene_Manager_Return_Scene_Set(_p_instance: MapBase3D, p_location: StringName, p_res: StringName) -> void:
	battle_ended.emit(p_location, p_res)

func _on_Result_closed() -> void:
	_tp_to_return_location()

func _on_Encounter_battle_ended(_p_location: StringName, p_res: StringName, p_EXP: int, p_loot: Dictionary[StringName, int]) -> void:
	_a_res = p_res
	
	match p_res:
		&"Flee": _tp_to_return_location()
		_: _a_Result.open(p_EXP, p_loot)
