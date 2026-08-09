extends FWExtensionBase
class_name FWCompMovementSharedBase

signal dir_vec_changed(p_dir_vec: Variant)

var _a_limit_dirs: bool
var _a_dir_names: Array[StringName]
var _a_reset_dir_vec: Variant # Vector

var _a_entity_entity: Node
var _a_entity_entity_comph: FWCompHandler
var _a_comph: FWCompHandler

var _a_velocity: Variant # Vector
var _a_dir_vec: Variant # Vector
var _a_base_speed: float = 0.0
var _a_speed: float = 0.0

func _init(p_entity: Node) -> void:
	super(p_entity)
	_a_comph = FWCompHandler.new(p_entity)

func ready() -> void:
	reset_dir_vec()
	_a_velocity = _a_entity.get_init_velocity()
	_update_speed()

func init(p_entities: Array[Node]) -> void:
	_a_entity_entity = p_entities[-1]
	_a_entity_entity_comph = _a_entity_entity.comph()
	
	var entities: Array[Node] = p_entities.duplicate()
	entities.push_back(_a_entity)
	_a_comph.register_comps(entities)

func comph() -> FWCompHandler:
	return _a_comph

func stop() -> void:
	_reset_velocity()
	_a_entity_entity_comph.call_comp("States", &"set_state_tmp", [&"Stop"])
	_a_entity_entity_comph.call_comp("Anims", &"update_anim")

func _update_speed() -> void:
	_a_speed = _a_base_speed
	var comps: Dictionary[StringName, Node] = _a_comph.get_comps()
	for instance: Node in comps.values():
		if instance.is_in_group(&"Movement"):
			_a_speed += instance.get_speed()
	
	if Input.is_action_pressed(&"Move_Run"):
		_a_speed *= 1.5

func _reset_velocity() -> void:
	_a_velocity = _a_entity.get_init_velocity()
	var comps: Dictionary[StringName, Node] = _a_comph.get_comps()
	for instance: Node in comps.values():
		if instance.is_in_group(&"Movement"):
			instance.reset_velocity()

func reset_dir_vec() -> void:
	set_dir_vec(_a_reset_dir_vec)

func get_velocity() -> Variant:
	return _a_velocity

func set_dir_vec(p_dir_vec: Variant) -> void:
	if _a_limit_dirs:
		var dir_name: StringName = Global.get_dir_vec_name(p_dir_vec)
		if !_a_dir_names.has(dir_name):
			return
	_a_dir_vec = p_dir_vec
	dir_vec_changed.emit(p_dir_vec)

func get_dir_vec() -> Variant:
	return _a_dir_vec

func get_dir_name() -> StringName:
	return Global.get_dir_vec_name(_a_dir_vec)

func set_base_speed(p_base_speed: float) -> void:
	_a_base_speed = p_base_speed

func get_speed() -> float:
	return _a_speed

func set_limit_dirs(p_limit_dirs: bool) -> void:
	_a_limit_dirs = p_limit_dirs

func set_dir_names(p_dir_names: Array[StringName]) -> void:
	_a_dir_names = p_dir_names

func set_reset_dir_vec(p_reset_dir_vec: Variant) -> void:
	_a_reset_dir_vec = p_reset_dir_vec

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Dir_Vec"] = _a_dir_vec
	data[&"Comps"] = {}
	var comps: Dictionary[StringName, Node] = _a_comph.get_comps()
	for key: StringName in comps:
		var instance: Node = comps[key]
		if instance == _a_entity:
			continue
		data[&"Comps"][key] = instance.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_dir_vec(p_data[&"Dir_Vec"])
	var comps: Dictionary[StringName, Node] = _a_comph.get_comps()
	for key: StringName in comps:
		var instance: Node = comps[key]
		if instance == _a_entity:
			continue
		instance.load_data(p_data[&"Comps"][key])
