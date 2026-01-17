extends DebugCommandEditCommandPreviewDimensions2D
class_name DebugCommandEditPreviewPlayAudioDimensions2D

func update_point() -> void:
	super()
	
	var preview_scene = _a_entity.get_preview_scene_instance()
	var point_vec: Vector2 = _a_point.get_point_vec()
	var grid_step: Vector2 = _a_grid_step.get_value()
	var grid_start: Vector2 = _a_grid_offset.get_value()
	var point_pos: Vector2 = Global.grid_point_to_pos(point_vec, grid_step, grid_start)
	var free_audio = preview_scene.get_free_audio()
	free_audio.set_position(point_pos)
