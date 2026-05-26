extends FWExtensionBase
class_name FWCutsceneThreadJumpDimensions2D

func tween_object_to_pos(p_tween: Tween, p_object: Object, p_pos: Vector2, p_duration: float) -> void:
	p_tween.tween_property(p_object, "global_position", p_pos, p_duration)
