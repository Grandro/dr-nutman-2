extends ExtensionBase
class_name CompMovementSharedBase

signal dir_changed(p_dir: StringName)

var _a_reset_dir: StringName

var _a_entity_entity: Node
var _a_entity_entity_comph: CompHandler
var _a_comph: CompHandler

var _a_velocity: Variant # Vector
var _a_dir: StringName = &"Down"
var _a_base_speed: float = 0.0
var _a_speed: float = 0.0

func _init(p_entity: Node) -> void:
	super(p_entity)
	_a_comph = CompHandler.new(p_entity)

func ready() -> void:
	reset_dir()
	_a_velocity = _a_entity.get_init_velocity()
	_update_speed()

func init(p_entity_entity: Node) -> void:
	_a_entity_entity = p_entity_entity
	_a_entity_entity_comph = _a_entity_entity.comph()
	
	_a_comph.register_comps(p_entity_entity)

func comph() -> CompHandler:
	return _a_comph

func stop() -> void:
	_reset_velocity()
	_a_entity_entity_comph.call_comp("States", &"set_state_tmp", [&"Stop"])
	_a_entity_entity_comph.call_comp("Anims", &"update_anim")

func _update_speed() -> void:
	_a_speed = _a_base_speed
	for child: Node in _a_entity.get_children():
		_a_speed += child.get_speed()

func _reset_velocity() -> void:
	_a_velocity = _a_entity.get_init_velocity()
	for child: Node in _a_entity.get_children():
		child.reset_velocity()

func reset_dir() -> void:
	set_dir(_a_reset_dir)

func get_velocity() -> Variant:
	return _a_velocity

func set_dir(p_dir: StringName) -> void:
	_a_dir = p_dir
	dir_changed.emit(p_dir)

func get_dir() -> StringName:
	return _a_dir

func set_base_speed(p_base_speed: float) -> void:
	_a_base_speed = p_base_speed

func get_speed() -> float:
	return _a_speed

func set_reset_dir(p_reset_dir: StringName) -> void:
	_a_reset_dir = p_reset_dir

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Dir"] = _a_dir
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_dir(p_data[&"Dir"])
