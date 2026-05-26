extends FWExtensionBase
class_name FWDebugTeleportMapDim3D

func handle_free_camera_pan(p_relative: Vector2) -> void:
	var free_camera: FWNode3DObject = _a_entity.get_free_camera_instance()
	free_camera.position.x -= p_relative.x * 0.03
	free_camera.position.z -= p_relative.y * 0.03

func get_global_mouse_pos() -> Variant:
	var mouse_pos: Vector2 = _a_entity.get_viewport().get_mouse_position()
	var free_camera: FWNode3DObject = _a_entity.get_free_camera_instance()
	var camera_comp: FWCompCamera3D = free_camera.comph().get_comp("Camera")
	var collision_mask: int = 1 # Terrain
	return Global.get_screen_pos_3D(mouse_pos, camera_comp, collision_mask)
