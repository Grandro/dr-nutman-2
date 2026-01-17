extends Node3D
class_name SVPartyMemberCompShieldBar

const _a_SHIELD_BAR_SCENE_PATH: String = "res://Global_Scenes/Battle_System/SV_Battle/Party_Members/Comps/Shield_Bar/Shield_Bars/%s/%s.tscn"

var _a_entity: SVPartyMember = null
var _a_entity_comph: CompHandler = null

var _a_instance: SVPartyMemberCompShieldBarBase # Shield_Bar instance of equipped Shield
var _a_max_shield: int
var _a_shield: int = 0

func _ready() -> void:
	hide()

func init(p_entity: SVPartyMember) -> void:
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()
	
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)

func open(p_shield_gain: int) -> void:
	_a_shield += p_shield_gain
	_a_instance.play_anim(&"Fade_In")
	
	show()

func _equip_shield(p_key: StringName) -> void:
	_a_instance = _instantiate_shield_bar(p_key)
	add_child(_a_instance)
	_a_max_shield = _a_instance.get_progress_max()

func _unequip_shield() -> void:
	_a_instance.queue_free()

func _instantiate_shield_bar(p_key: StringName) -> SVPartyMemberCompShieldBarBase:
	var scene: PackedScene = load(_a_SHIELD_BAR_SCENE_PATH % [p_key, p_key])
	var instance: SVPartyMemberCompShieldBarBase = scene.instantiate()
	instance.anim_finished.connect(_on_Shield_Bar_anim_finished)
	instance.progress_updated.connect(_on_Shield_Bar_progress_updated)
	
	return instance

func _update_progress() -> void:
	_a_instance.update_progress(_a_shield)

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass

func _on_Comp_Handler_comps_registered() -> void:
	var equipment_comp: CompEquipment3D = _a_entity_comph.get_comp("Equipment")
	equipment_comp.equipped.connect(_on_Equipment_equipped)
	equipment_comp.unequipped.connect(_on_Equipment_unequipped)
	
	var shield_key: StringName = equipment_comp.get_equipable(&"Shield")
	if shield_key.is_empty():
		_equip_shield(&"None")
	else:
		_equip_shield(shield_key)

func _on_Shield_Bar_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Fade_In": _update_progress()
		&"Fade_Out": hide()

func _on_Shield_Bar_progress_updated() -> void:
	if _a_shield >= _a_max_shield:
		_a_shield = 0
		_a_instance.set_progress_value(0)
		_a_instance.process_effect(_a_entity)
	
	_a_instance.play_anim(&"Fade_Out")

func _on_Equipment_equipped(p_group: StringName, p_key: StringName) -> void:
	if p_group != &"Shield":
		return
	_equip_shield(p_key)

func _on_Equipment_unequipped(p_group: StringName) -> void:
	if p_group != &"Shield":
		return
	_unequip_shield()
