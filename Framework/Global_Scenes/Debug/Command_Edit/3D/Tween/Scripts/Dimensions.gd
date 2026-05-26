extends FWDebugCommandEditPreviewDimensions3D
class_name FWDebugCommandEditPreviewTweenDimensions3D

var _a_Start_Sprite: Texture2D = preload("uid://mxhxrvn746cu")
var _a_End_Sprite: Texture2D = preload("uid://dt70asssy8c3g")

var _a_start_point_vec: Vector3
var _a_end_point_vec: Vector3

func update_start_point(p_pos: Vector3) -> void:
	var start_point: Sprite3D = _a_entity.get_start_point_instance()
	var grid_offset: Vector3 = _a_grid_offset.get_value()
	var scale_: Vector3 = _a_grid_step.get_value()
	start_point.set_position(p_pos + grid_offset + Vector3(0.0, 0.01, 0.0))
	start_point.set_scale(scale_)
	start_point.set_texture(_a_Start_Sprite)
	
	_a_start_point_vec = p_pos

func update_end_point(p_pos: Vector3) -> void:
	var end_point: Sprite3D = _a_entity.get_end_point_instance()
	var grid_offset: Vector3 = _a_grid_offset.get_value()
	var scale_: Vector3 = _a_grid_step.get_value()
	end_point.set_position(p_pos + grid_offset + Vector3(0.0, 0.01, 0.0))
	end_point.set_scale(scale_)
	end_point.set_texture(_a_End_Sprite)
	
	_a_end_point_vec = p_pos

func get_start_point_vec() -> Vector3:
	return _a_start_point_vec

func get_end_point_vec() -> Vector3:
	return _a_end_point_vec

func is_value_vector(p_value: Variant) -> bool:
	return typeof(p_value) == TYPE_VECTOR3
