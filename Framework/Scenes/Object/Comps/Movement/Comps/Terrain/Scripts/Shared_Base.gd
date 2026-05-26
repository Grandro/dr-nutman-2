extends FWExtensionBase
class_name FWCompMovementTerrainAreaSharedBase

var _a_Areas: Node

var _a_entity_entity_comph: FWCompHandler
var _a_movement: Node

var _a_audio_base_path: String # (String, DIR)
var _a_veil_base_path: String # (String, DIR)

func init(p_entities: Array[Node]) -> void:
	_a_entity_entity_comph = p_entities[-2].comph()
	_a_movement = p_entities[-1]
	_a_entity_entity_comph.comps_registered.connect(_on_Entity_Entity_Comph_comps_registered)
	
	reset_velocity()

func ready() -> void:
	_a_Areas = _a_entity.get_node("Areas")
	
	for child: Node in _a_Areas.get_children():
		child.set_audio_base_path(_a_audio_base_path)
		child.set_veil_base_path(_a_veil_base_path)

func play_audio(p_key: String) -> void:
	var instance: Node = _a_Areas.get_node(p_key)
	instance.play_audio()

func set_audio_base_path(p_audio_base_path: String) -> void:
	_a_audio_base_path = p_audio_base_path

func set_veil_base_path(p_veil_base_path: String) -> void:
	_a_veil_base_path = p_veil_base_path

func reset_velocity() -> void:
	pass

func adjust_velocity_post(p_velocity: Variant) -> Variant:
	var children: Array[Node] = _a_Areas.get_children()
	var last_areas: Array[Node] = []
	for child: Node in children:
		var areas: Array[Node] = child.get_areas()
		if !areas.is_empty():
			last_areas.push_back(areas[-1])
	
	if last_areas.is_empty():
		return p_velocity
	
	var speed_mult: float = 0.0
	for last_area: Node in last_areas:
		speed_mult += last_area.get_speed_mult()
	speed_mult /= last_areas.size()
	
	return p_velocity * speed_mult

func get_velocity() -> Variant:
	return _a_movement.get_init_velocity()

func get_speed() -> float:
	return 0.0

func _on_Entity_Entity_Comph_comps_registered() -> void:
	if _a_entity_entity_comph.has_comp("Movement/Jump"):
		var jump_comp: FWCompMovementJumpBase = _a_entity_entity_comph.get_comp("Movement/Jump")
		jump_comp.jumped.connect(_on_Movement_Jump_jumped)

func _on_Movement_Jump_jumped() -> void:
	for child: Node in _a_Areas.get_children():
		child.play_audio()
