extends ExtensionBase
class_name CutsceneThreadJumpDimensions3D

func tween_object_to_pos(p_tween: Tween, p_object: Object, p_pos: Vector3, p_duration: float) -> void:
	p_tween.set_parallel(true)
	p_tween.tween_property(p_object, "global_position:x", p_pos.x, p_duration)
	p_tween.tween_property(p_object, "global_position:z", p_pos.z, p_duration)
