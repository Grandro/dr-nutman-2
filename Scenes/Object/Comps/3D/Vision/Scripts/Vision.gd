extends Node3D
class_name CompVision3D

@export var _e_range: float = 10.0

var _a_entity: Node3D
var _a_entity_comph: CompHandler

var _a_enabled: int = 0 # 0 = disabled, >0 = enabled

func init(p_entity: Node3D) -> void:
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()
	
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

func _update_rotation_deg(p_dir: StringName) -> void:
	var dir_rotation_deg: Vector3 = Global.get_dir_rotation_deg(p_dir)
	set_rotation_degrees(dir_rotation_deg)

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
		var dir: StringName = _a_entity_comph.call_comp("Movement", &"get_dir")
		_update_rotation_deg(dir)
	
	if p_enabled == (_a_enabled > 0):
		return
	
	if _a_entity_comph.has_comp("Movement"):
		var movement_comp: CompMovementBase3D = _a_entity_comph.get_comp("Movement")
		if p_enabled:
			movement_comp.dir_changed.connect(_on_Movement_dir_changed)
		else:
			movement_comp.dir_changed.disconnect(_on_Movement_dir_changed)

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

func _on_Movement_dir_changed(p_dir: StringName) -> void:
	_update_rotation_deg(p_dir)
