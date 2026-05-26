extends FWDebugCommandEditPreviewDimensions3D
class_name FWDebugCommandEditPreviewPlayAudioDimensions3D

func update_point() -> void:
	super()
	
	var preview_scene: FWMapBase3D = _a_entity.get_preview_scene_instance()
	var point_vec: Vector3 = _a_point.get_point_vec()
	var grid_step: Vector3 = _a_grid_step.get_value()
	var grid_start: Vector3 = _a_grid_offset.get_value()
	var point_pos: Vector3 = Global.grid_point_to_pos(point_vec, grid_step, grid_start)
	var free_audio: FWPausableAudio3D = preview_scene.get_free_audio()
	free_audio.set_position(point_pos)
