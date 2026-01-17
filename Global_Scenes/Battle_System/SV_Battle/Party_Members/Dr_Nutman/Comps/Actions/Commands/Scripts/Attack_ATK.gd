extends SVActionCommandAttackATK
class_name SVDrNutmanActionCommandAttackATK

func _moved_to_target() -> void:
	_a_entity.set_action_on_cd(false)
	_a_entity.set_action_diff(0.0)
	_a_States.set_state_tmp(&"Attack_ATK_Charge")
	_a_Anims.update_anim()
	
	_a_entity.set_process_unhandled_input(true)

func _on_Hitbox_body_entered(p_body: Node3D) -> void:
	pre_event.emit()
	
	super(p_body)
	_a_entity.set_process_unhandled_input(false)
	
	post_event.emit()
	
	await get_tree().create_timer(1.0).timeout
	_a_States.set_state(&"Walk")
	_a_Movement.set_state(&"Move_To_Org_Pos")
	_a_Movement.move_to_org_pos()
	_a_Anims.update_anim()

func _on_Anims_anim_finished(p_name: StringName) -> void:
	if "Attack_ATK_Charge" in p_name:
		_a_entity.set_process_unhandled_input(false)
		_a_States.set_state_tmp(&"Attack_ATK_Tumble")
		_a_Anims.update_anim()
		
		await get_tree().create_timer(1.0).timeout
		
		_a_States.set_state_tmp(&"Attack_ATK_Fall")
		_a_Anims.update_anim()
	
	elif "Attack_ATK_Fall" in p_name:
		_a_States.set_state_tmp(&"Attack_ATK_Recover")
		_a_Anims.update_anim()
	
	elif "Attack_ATK_Recover" in p_name:
		_a_States.set_state(&"Walk")
		_a_Movement.set_state(&"Move_To_Org_Pos")
		_a_Movement.move_to_org_pos()
		_a_Anims.update_anim()
