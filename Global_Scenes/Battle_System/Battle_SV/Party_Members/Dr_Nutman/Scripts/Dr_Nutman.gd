extends "res://Global_Scenes/Battle_System/Battle_SV/Party_Members/Scripts/Party_Member_Battle.gd"

func process_action_start():
	super()
	match _a_command:
		"Attack_ATK": _process_action_attack_ATK()
		"Defense_DEF": _process_action_defense_DEF()
		"Special": _process_action_special()
		"Flee": _process_action_flee()

func _process_action_attack_ATK():
	var target_pos = _a_target.get_global_position()
	var attack_offset = _a_target.get_attack_offset()
	var end_pos = target_pos + attack_offset
	_a_States.set_state("Walk")
	_a_Movement.set_state("Move_To_Enemy")
	_a_Movement.reset_dir()
	_a_Movement.move_to_pos(end_pos)
	_a_Anims.update_anim()

func _process_action_defense_DEF():
	_emit_turn_completed()

func _process_action_special():
	pass

func _attack_ATK():
	_a_action_on_cd = false
	_a_action_dif = 0.0
	_a_States.set_state_tmp("Attack_ATK_Charge")
	_a_Anims.update_anim()
	
	set_process_unhandled_input(true)

func _CB_enemy_hit_anim():
	action_pre_event.emit()
	
	var rating = _get_timing_rating()
	_a_encounter.deal_damage_enemy(self, _a_target, rating)
	set_process_unhandled_input(false)
	
	action_post_event.emit()
	
	await get_tree().create_timer(1.0).timeout
	_a_States.set_state("Walk")
	_a_Movement.set_state("Move_To_Org_Pos")
	_a_Movement.move_to_org_pos()
	_a_Anims.update_anim()

func _on_Movement_Nav_Agent_path_finished():
	super()
	
	var state = _a_Movement.get_state()
	match state:
		"Move_To_Enemy":
			_attack_ATK()
		
		"Move_To_Org_Pos":
			_a_States.set_state_tmp("Idle")
			_a_Movement.reset_dir()
			_a_Anims.update_anim()
			
			_emit_turn_completed()

func _on_Anims_anim_finished(p_name):
	super(p_name)
	
	if "Attack_ATK_Charge" in p_name:
		set_process_unhandled_input(false)
		_a_States.set_state_tmp("Attack_ATK_Tumble")
		_a_Anims.update_anim()
		
		await get_tree().create_timer(1.0).timeout
		
		_a_States.set_state_tmp("Attack_ATK_Fall")
		_a_Anims.update_anim()
	
	elif "Attack_ATK_Fall" in p_name:
		_a_States.set_state_tmp("Attack_ATK_Recover")
		_a_Anims.update_anim()
	
	elif "Attack_ATK_Recover" in p_name:
		_a_States.set_state("Walk")
		_a_Movement.set_state("Move_To_Org_Pos")
		_a_Movement.move_to_org_pos()
		_a_Anims.update_anim()
