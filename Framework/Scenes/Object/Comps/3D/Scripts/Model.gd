extends Node3D
class_name FWCompModel3D

var _a_entity_comph: FWCompHandler

var _a_tween: Tween = null

func init(p_entities: Array[Node]) -> void:
	_a_entity_comph = p_entities[-1].comph()
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)
	
	if _a_entity_comph.has_comp("Movement"):
		var movement_comp: FWCompMovementBase3D = _a_entity_comph.get_comp("Movement")
		movement_comp.dir_vec_changed.connect(_on_Movement_dir_vec_changed)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Transform"] = get_transform()
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_transform(p_data[&"Transform"])

func load_data_init() -> void:
	pass

func _on_Comp_Handler_comps_registered() -> void:
	var anims_comp: FWCompAnims = _a_entity_comph.get_comp("Anims")
	anims_comp.set_root_node("../Model/Model")

func _on_Movement_dir_vec_changed(p_dir_vec: Vector3) -> void:
	var dir_vec: Vector3 = Vector3(p_dir_vec.x, 0.0, p_dir_vec.z)
	var from: float = rotation.y
	var to: float = deg_to_rad(Global.get_dir_vec_rotation_deg_3D(dir_vec))
	
	if _a_tween != null:
		_a_tween.kill()
	_a_tween = create_tween()
	_a_tween.tween_method(func(x): rotation.y = lerp_angle(from, to, x), 0.0, 1.0, 0.1)
