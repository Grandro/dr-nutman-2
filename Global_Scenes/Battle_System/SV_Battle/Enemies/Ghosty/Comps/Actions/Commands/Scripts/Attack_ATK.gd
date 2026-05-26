extends SVActionCommandAttackATK
class_name SVEnemyGhostyCompActionsCommandAttackATK

var _a_Display: FWCompDisplay3D
var _a_Collision: FWCompCollisionShape3D

func init(p_commands: SVActionsBase, p_entity: SVCharacter) -> void:
	super(p_commands, p_entity)
	_a_Display = p_entity.comph().get_comp("Display")
	_a_Collision = p_entity.comph().get_comp("Collision")

func process() -> void:
	_a_Collision.set_disabled(true)
	_a_Hitbox.set_monitoring(true)
	super()

func _moved_to_target() -> void:
	reaction_finished.emit()
	_a_Collision.set_disabled(false)
	_a_Hitbox.set_monitoring(false)
	
	var tween: Tween = _tween_display_modulate(Color.TRANSPARENT, Color.WHITE)
	tween.finished.connect(_moved_to_org_pos)
	
	var org_pos: Vector3 = _a_Movement.get_org_pos()
	_a_entity.set_global_position(org_pos)

func _tween_display_modulate(p_from: Color, p_to: Color) -> Tween:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_a_Display, "modulate", p_to, 0.5).from(p_from)
	
	return tween
