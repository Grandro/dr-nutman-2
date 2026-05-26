extends Node
class_name FWCompMovementStatesBase

@export var _e_speeds: Dictionary[StringName, float] = {} # Match state to speed

var _a_movement: Node

var _a_speed: float = 0.0

func init(p_entities: Array[Node]) -> void:
	var entity_entity_comph: FWCompHandler = p_entities[-2].comph()
	_a_movement = p_entities[-1]
	
	var states_comp: FWCompStates = entity_entity_comph.get_comp("States")
	states_comp.state_tmp_changed.connect(_on_States_state_tmp_changed)

func reset_velocity() -> void:
	pass

func adjust_velocity_post(p_velocity: Variant) -> Variant:
	return p_velocity

func get_velocity_() -> Variant:
	return _a_movement.get_init_velocity()

func get_speed() -> float:
	return _a_speed

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass

func _on_States_state_tmp_changed(p_state_tmp: StringName) -> void:
	if _e_speeds.has(p_state_tmp):
		_a_speed = _e_speeds[p_state_tmp]
