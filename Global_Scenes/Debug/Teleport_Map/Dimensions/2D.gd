extends ExtensionBase
class_name DebugTeleportMapDim2D

func handle_free_camera_pan(p_relative: Vector2) -> void:
	var free_camera: Node2DObject = _a_entity.get_free_camera_instance()
	free_camera.position -= p_relative

func get_global_mouse_pos() -> Vector2:
	var curr_scene: Node2D = Scene_Manager.get_curr_scene_instance()
	var global_pos: Vector2 = curr_scene.get_global_mouse_position()
	
	return global_pos
