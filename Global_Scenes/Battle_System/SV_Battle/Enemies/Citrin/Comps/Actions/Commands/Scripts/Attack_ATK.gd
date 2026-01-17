extends SVActionCommandAttackATK
class_name SVEnemyCitrinActionCommandAttackATK

func _moved_to_target() -> void:
	_a_States.set_state(&"Attack")
	_a_Anims.update_anim()
	
	pre_event.emit()

func _on_Anims_anim_finished(p_name: StringName) -> void:
	if "Attack" in p_name:
		post_event.emit()
		
		_a_States.set_state(&"Walk")
		_a_Movement.set_state(&"Move_To_Org_Pos")
		_a_Movement.move_to_org_pos()
		_a_Anims.update_anim()
		await get_tree().create_timer(1.0).timeout
		
		reaction_finished.emit()
