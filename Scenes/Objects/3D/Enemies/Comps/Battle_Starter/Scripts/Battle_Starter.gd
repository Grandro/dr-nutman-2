extends Node3D
class_name CompBattleStarter3D

signal battle_starting()

@export var _e_enc_key: StringName = &""
@export var _e_troops: Dictionary[Array, int] = {}
@export var _e_bonus_loot: Dictionary = {}

var _a_entity: Node3D = null

var _a_troops_RNG = FWDicRNG.new()

func _ready() -> void:
	for child in get_children():
		child.area_entered.connect(_on_Area_area_entered.bind(child))
		child.body_entered.connect(_on_Area_body_entered.bind(child))
	
	_a_troops_RNG.set_dic(_e_troops)

func init(p_entities: Array[Node]) -> void:
	_a_entity = p_entities[-1]
	_a_entity.visibility_changed.connect(_on_entity_visibility_changed)

func start_battle(p_map_res: BattleSV.MAP_RES) -> void:
	var troop: Array[StringName]; troop.assign(_a_troops_RNG.roll_key())
	var battle_system_si: Battle_System = Global.get_singleton(self, "Battle_System")
	var battle_sv: BattleSV = battle_system_si.get_battle_sv()
	var bonus_loot: Dictionary = _e_bonus_loot.duplicate()
	battle_starting.emit()
	battle_sv.battle(_e_enc_key, p_map_res, troop, bonus_loot)

func add_bonus_loot(p_key: StringName, p_dic: Dictionary[int, int]) -> void:
	_e_bonus_loot[p_key] = p_dic

func remove_bonus_loot(p_key: StringName) -> void:
	_e_bonus_loot.erase(p_key)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Enc_Key"] = _e_enc_key
	data[&"Troops"] = _e_troops
	data[&"Bonus_Loot"] = _e_bonus_loot
	
	return data

func load_data(p_data: Dictionary) -> void:
	_e_enc_key = p_data[&"Enc_Key"]
	_e_troops = p_data[&"Troops"]
	_e_bonus_loot = p_data[&"Bonus_Loot"]

func load_data_init() -> void:
	pass

func _on_Area_area_entered(_p_area, p_instance) -> void:
	var res: BattleSV.MAP_RES = p_instance.get_res()
	start_battle(res)

func _on_Area_body_entered(_p_body, p_instance) -> void:
	var res: BattleSV.MAP_RES = p_instance.get_res()
	start_battle(res)

func _on_entity_visibility_changed() -> void:
	var is_visible_: bool = _a_entity.is_visible()
	for child in get_children():
		child.set_monitoring.call_deferred(is_visible_)
