extends DebugCommandEditCommandPreviewDimensions2D
class_name DebugCommandEditPreviewTweenDimensions2D

var _a_Start_Sprite: Texture2D = preload("res://Global_Scenes/Debug/Sprites/Path/Start.png")
var _a_End_Sprite: Texture2D = preload("res://Global_Scenes/Debug/Sprites/Path/End.png")

func update_start_point(p_pos: Vector2) -> void:
	var start_point: Sprite2D = _a_entity.get_start_point_instance()
	var grid_offset: Vector2 = _a_grid_offset.get_value()
	var scale_: Vector2 = _a_grid_step.get_value() / 50.0
	start_point.set_position(p_pos + grid_offset)
	start_point.set_scale(scale_)
	start_point.set_texture(_a_Start_Sprite)

func update_end_point(p_pos: Vector2) -> void:
	var end_point: Sprite2D = _a_entity.get_end_point_instance()
	var grid_offset: Vector2 = _a_grid_offset.get_value()
	var scale_: Vector2 = _a_grid_step.get_value() / 50.0
	end_point.set_position(p_pos + grid_offset)
	end_point.set_scale(scale_)
	end_point.set_texture(_a_End_Sprite)

func is_value_vector(p_value: Variant) -> bool:
	return typeof(p_value) == TYPE_VECTOR2
