extends FWExtensionBase
class_name FWCompMovementSharedBase

signal dir_changed(p_dir: StringName)

var _a_dirs: Array[StringName]
var _a_reset_dir: StringName

var _a_entity_entity: Node
var _a_entity_entity_comph: FWCompHandler
var _a_comph: FWCompHandler

var _a_velocity: Variant # Vector
var _a_dir: StringName
var _a_base_speed: float = 0.0
var _a_speed: float = 0.0

func _init(p_entity: Node) -> void:
	super(p_entity)
	_a_comph = FWCompHandler.new(p_entity)

func ready() -> void:
	reset_dir()
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

func _reset_velocity() -> void:
	_a_velocity = _a_entity.get_init_velocity()
	var comps: Dictionary[StringName, Node] = _a_comph.get_comps()
	for instance: Node in comps.values():
		if instance.is_in_group(&"Movement"):
			instance.reset_velocity()

func reset_dir() -> void:
	set_dir(_a_reset_dir)

func get_velocity() -> Variant:
	return _a_velocity

func set_dir(p_dir: StringName) -> void:
	if _a_dirs.has(p_dir):
		_a_dir = p_dir
		dir_changed.emit(p_dir)

func get_dir() -> StringName:
	return _a_dir

func set_base_speed(p_base_speed: float) -> void:
	_a_base_speed = p_base_speed

func get_speed() -> float:
	return _a_speed

func set_dirs(p_dirs: Array[StringName]) -> void:
	_a_dirs = p_dirs
	if !p_dirs.is_empty():
		_a_dir = p_dirs[0]

func set_reset_dir(p_reset_dir: StringName) -> void:
	_a_reset_dir = p_reset_dir

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Dir"] = _a_dir
	data[&"Comps"] = {}
	var comps: Dictionary[StringName, Node] = _a_comph.get_comps()
	for key: StringName in comps:
		var instance: Node = comps[key]
		if instance == _a_entity:
			continue
		data[&"Comps"][key] = instance.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_dir(p_data[&"Dir"])
	
	var comps: Dictionary[StringName, Node] = _a_comph.get_comps()
	for key: StringName in comps:
		var instance: Node = comps[key]
		if instance == _a_entity:
			continue
		instance.load_data(p_data[&"Comps"][key])
