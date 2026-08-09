extends Node3D
class_name FWCompVision3D

@export var _e_range: float = 10.0

var _a_entity: Node3D
var _a_entity_comph: FWCompHandler

var _a_enabled: int = 0 # 0 = disabled, >0 = enabled

func init(p_entities: Array[Node]) -> void:
	_a_entity = p_entities[-1]
	_a_entity_comph = _a_entity.comph()
	
	var target_pos: Vector3 = Vector3(0.0, 0.0, 1.0) * _e_range
	for child: RayCast3D in get_children():
		child.set_target_position(target_pos)

func enable() -> void:
	if _a_enabled == 0:
		_set_enabled(true)
	_a_enabled += 1

func disable() -> void:
	if _a_enabled == 1:
		_set_enabled(false)
	_a_enabled -= 1

func _update_rotation_deg(p_dir_vec: Vector3) -> void:
	var pos: Vector3 = get_global_position() + p_dir_vec
	look_at(pos, Vector3.UP, true)

func can_see_instance(p_instance: Node3D) -> bool:
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var pos: Vector3 = p_instance.get_global_position()
	if entity_pos.distance_to(pos) > _e_range:
		return false
	
	for child: RayCast3D in get_children():
		if !child.is_colliding():
			continue
		
		var collider: Object = child.get_collider()
		if collider == p_instance:
			return true
	
	return false

func _set_enabled(p_enabled: bool) -> void:
	for child: RayCast3D in get_children():
		child.set_enabled(p_enabled)
	
	if p_enabled:
		var dir_vec: Vector3 = _a_entity_comph.call_comp("Movement", &"get_dir_vec")
		_update_rotation_deg(dir_vec)
	
	if p_enabled == (_a_enabled > 0):
		return
	
	if _a_entity_comph.has_comp("Movement"):
		var movement_comp: FWCompMovementBase3D = _a_entity_comph.get_comp("Movement")
		if p_enabled:
			movement_comp.dir_vec_changed.connect(_on_Movement_dir_vec_changed)
		else:
			movement_comp.dir_vec_changed.disconnect(_on_Movement_dir_vec_changed)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Range"] = _e_range
	data[&"Enabled"] = _a_enabled
	
	return data

func load_data(p_data: Dictionary) -> void:
	await _a_entity_comph.comps_registered
	
	_e_range = p_data[&"Range"]
	_set_enabled(p_data[&"Enabled"] > 0)
	_a_enabled = p_data[&"Enabled"]

func load_data_init() -> void:
	await _a_entity_comph.comps_registered
	
	_set_enabled(false)

func _on_Movement_dir_vec_changed(p_dir_vec: Vector3) -> void:
	_update_rotation_deg(p_dir_vec)
