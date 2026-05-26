extends Node2D
class_name FWCompEquipment2D

signal equipped(p_group: StringName, p_key: StringName)
signal unequipped(p_group: StringName)

@export var _e_scenes: Dictionary = {&"Head": {}, &"Torso": {}, &"Legs": {}, &"Feet": {}}

var _a_Shared: GDScript = preload("uid://ckekh5cpwyrdl")

var _a_shared: FWCompEquipmentShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.equipped.connect(_on_Shared_equipped)
	_a_shared.unequipped.connect(_on_Shared_unequipped)
	_a_shared.set_scenes(_e_scenes)
	
	_a_shared.ready()

func init(p_entities: Array[Node]) -> void:
	_a_shared.init(p_entities)

func play_anim_all(p_name: StringName, p_speed: float, p_backwards: bool) -> void:
	_a_shared.play_anim_all(p_name, p_speed, p_backwards)

func seek_anim_all(p_seconds: float, p_update: bool) -> void:
	_a_shared.seek_anim_all(p_seconds, p_update)

func stop_anim_all(p_keep_state: bool) -> void:
	_a_shared.stop_anim_all(p_keep_state)

func equip_both(p_group: StringName, p_key: StringName) -> void:
	_a_shared.equip_both(p_group, p_key)

func equip(p_group: StringName, p_key: StringName) -> void:
	_a_shared.equip(p_group, p_key)

func unequip_both(p_group: StringName) -> void:
	_a_shared.unequip_both(p_group)

func unequip(p_group: StringName) -> void:
	_a_shared.unequip(p_group)

func get_scenes() -> Dictionary:
	return _a_shared.get_scenes()

func get_equipable(p_group: StringName) -> StringName:
	return _a_shared.get_equipable(p_group)

func get_equipables() -> Dictionary[StringName, StringName]:
	return _a_shared.get_equipables()

func get_save_data() -> Dictionary:
	return _a_shared.get_save_data()

func load_data(p_data: Dictionary) -> void:
	_a_shared.load_data(p_data)

func load_data_init() -> void:
	_a_shared.load_data_init()

func _on_Shared_equipped(p_group: StringName, p_key: StringName) -> void:
	equipped.emit(p_group, p_key)

func _on_Shared_unequipped(p_group: StringName) -> void:
	unequipped.emit(p_group)
