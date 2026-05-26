extends Node
class_name FWCompMovementControllerBase

var _a_entity: Node
var _a_entity_comph: FWCompHandler
var _a_movement: Node
var _a_movement_comph: FWCompHandler

var _a_velocity: Variant # Vector

func _ready() -> void:
	set_physics_process(false)

func _physics_process(_p_delta: float) -> void:
	_process_move()

func init(p_entities: Array[Node]) -> void:
	_a_entity = p_entities[-2]
	_a_entity_comph = _a_entity.comph()
	_a_movement = p_entities[-1]
	_a_movement_comph = _a_movement.comph()
	
	if _a_entity_comph.has_comp("Operate"):
		var operate_comp: FWCompOperate = _a_entity_comph.get_comp("Operate")
		operate_comp.to_disabled.connect(_on_Operate_to_disabled)
		operate_comp.to_enabled.connect(_on_Operate_to_enabled)
		tree_exiting.connect(_on_tree_exiting)
	
	set_physics_process(true)

func _process_move() -> void:
	_a_velocity = _get_input_velocity()
	_a_velocity = _a_velocity.normalized()
	
	if _a_velocity.length() > 0.0:
		var dir: StringName = Global.get_vec_dir(_a_velocity)
		_a_movement.set_dir(dir)
	
	_change_state(_a_velocity)
	_a_velocity *= _a_movement.get_speed()

func _change_state(p_velocity: Variant) -> void:
	if p_velocity.length() > 0.0:
		_a_entity_comph.call_comp("States", &"set_state_tmp", [&"Walk"])
	else:
		_a_entity_comph.call_comp("States", &"set_state_tmp", [&"Stop"])

func reset_velocity() -> void:
	_a_velocity = _a_movement.get_init_velocity()

func adjust_velocity_post(p_velocity: Variant) -> Variant:
	return p_velocity

func get_velocity_() -> Variant:
	return _a_velocity

func get_speed() -> float:
	return 0.0

func _get_input_velocity() -> Variant:
	return null

func _is_on_floor() -> bool:
	return false

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass

func _on_Operate_to_disabled() -> void:
	set_physics_process(false)
	reset_velocity()
	_a_movement.stop()

func _on_Operate_to_enabled() -> void:
	set_physics_process(true)

func _on_tree_exiting() -> void:
	var operate_comp: FWCompOperate = _a_entity_comph.get_comp("Operate")
	operate_comp.to_disabled.disconnect(_on_Operate_to_disabled)
	operate_comp.to_enabled.disconnect(_on_Operate_to_enabled)
