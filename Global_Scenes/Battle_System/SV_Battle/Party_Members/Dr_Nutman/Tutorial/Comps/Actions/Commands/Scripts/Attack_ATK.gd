extends SVDrNutmanActionCommandAttackATK
class_name SVDrNutmanTutorialActionCommandAttackATK

var _a_progress_si: Progress = null
var _a_show_tutato_explain: bool = true

func _ready() -> void:
	_a_progress_si = Global.get_singleton(self, "Progress")
	_a_show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()

func _moved_to_target() -> void:
	var explain_attack: bool = _a_progress_si.call_object(&"Tutato", &"get_explain_battle_attack")
	if _a_show_tutato_explain && explain_attack:
		_a_States.set_state_tmp(&"Idle")
		_a_Anims.update_anim()
		_a_entity.cutscene(&"Explain_Attack_1", &"0", _CB_cutscene_completed)
	else:
		super()

func _CB_cutscene_completed(_p_process_type: StringName, p_key: StringName, p_entry_key: StringName) -> void:
	match p_key:
		&"Explain_Attack_1":
			match p_entry_key:
				&"0":
					_a_entity.cutscene(&"Tutato_Explain", &"First_Battle_Attack_1",
									   _CB_cutscene_completed, &"Main", &"Global")
		
		&"Tutato_Explain":
			match p_entry_key:
				&"First_Battle_Attack_1":
					_a_States.set_state_tmp(&"Attack_ATK_Charge")
					_a_Anims.update_anim()
				
				&"First_Battle_Attack_2":
					_a_entity.stop_action_button_blink()
					
					_a_Audio.play("Perform")
					_a_States.set_state_tmp(&"Attack_ATK_Hit")
					_a_Anims.update_anim()
					
					_a_entity.set_action_on_cd(true)
					_a_entity.set_action_diff(0.0)
					hit.emit()
					
					await get_tree().create_timer(1.0).timeout
					
					_a_entity.cutscene(&"Tutato_Explain", &"First_Battle_Attack_3",
									   _CB_cutscene_completed, &"Main", &"Global")
				
				&"First_Battle_Attack_3":
					_a_States.set_state(&"Walk")
					_a_Movement.set_state(&"Move_To_Org_Pos")
					_a_Movement.move_to_org_pos()
					_a_Anims.update_anim()
					_a_progress_si.call_object(&"Tutato", &"set_explain_battle_attack", [false])

func _on_Hitbox_body_entered(p_body: Node3D) -> void:
	var explain_attack: bool = _a_progress_si.call_object(&"Tutato", &"get_explain_battle_attack")
	if !_a_show_tutato_explain || !explain_attack:
		super(p_body)

func _on_Anims_anim_finished(p_name: StringName) -> void:
	var explain_attack: bool = _a_progress_si.call_object(&"Tutato", &"get_explain_battle_attack")
	if _a_show_tutato_explain && explain_attack:
		match p_name:
			&"SV/Attack_ATK_Charge_Right":
				_a_entity.start_action_button_blink()
				_a_entity.cutscene(&"Tutato_Explain", &"First_Battle_Attack_2",
								   _CB_cutscene_completed, &"Main", &"Global")
			_:
				super(p_name)
	else:
		super(p_name)
