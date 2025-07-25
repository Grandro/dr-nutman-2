extends "res://Global_Scenes/Battle_System/Battle_SV/Party_Members/Dr_Nutman/Scripts/Dr_Nutman.gd"

@onready var _a_Action_Button = get_node("Action_Button")
@onready var _a_Action_Button_Anims = get_node("Action_Button/Anims")

var _a_progress_si = null
var _a_show_tutato_explain = true

func _ready():
	_a_progress_si = Global.get_singleton(self, "Progress")
	_a_show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()
	
	super()
	_a_Action_Button.hide()

func start_action_button_blink():
	_a_Action_Button_Anims.play("Blink")
	_a_Action_Button.show()

func stop_action_button_blink():
	_a_Action_Button_Anims.stop()
	_a_Action_Button.hide()

func _process_action_flee():
	_cutscene("Flee_Attempt_1", "0", _CB_cutscene_completed)

func _explain_attack_ATK():
	_cutscene("Explain_Attack_1", "0", _CB_cutscene_completed)

func _CB_cutscene_completed(_p_process_type, p_key, p_entry_key):
	match p_key:
		"Explain_Attack_1":
			match p_entry_key:
				"0":
					_cutscene("Tutato_Explain", "First_Battle_Attack_1", _CB_cutscene_completed, "Main", "Global")
		
		"Flee_Attempt_1":
			_emit_turn_canceled()
		
		"Tutato_Explain":
			match p_entry_key:
				"First_Battle_Attack_1":
					_a_States.set_state_tmp("Attack_ATK_Charge")
					_a_Anims.update_anim()
				"First_Battle_Attack_2":
					stop_action_button_blink()
					
					_a_Audio.play("Perform")
					_a_States.set_state_tmp("Attack_ATK_Hit")
					_a_Anims.update_anim()
					_a_encounter.deal_damage_enemy(self, _a_target, "Excellent")
					
					await get_tree().create_timer(1.0).timeout
					
					_cutscene("Tutato_Explain", "First_Battle_Attack_3", _CB_cutscene_completed, "Main", "Global")
				"First_Battle_Attack_3":
					_a_States.set_state("Walk")
					_a_Movement.set_state("Move_To_Org_Pos")
					_a_Movement.move_to_org_pos()
					_a_Anims.update_anim()
					_a_progress_si.call_object("Tutato", "set_explain_battle_attack", [false])

func _CB_enemy_hit_anim():
	var explain_attack = _a_progress_si.call_object("Tutato", "get_explain_battle_attack")
	if !_a_show_tutato_explain || !explain_attack:
		super()

func _on_Movement_Nav_Agent_path_finished():
	var state = _a_Movement.get_state()
	match state:
		"Move_To_Enemy":
			var explain_attack = _a_progress_si.call_object("Tutato", "get_explain_battle_attack")
			if _a_show_tutato_explain && explain_attack:
				_a_States.set_state_tmp("Idle")
				_a_Anims.update_anim()
				_explain_attack_ATK()
			else:
				_attack_ATK()
		
		_:
			super()

func _on_Anims_anim_finished(p_name):
	var explain_attack = _a_progress_si.call_object("Tutato", "get_explain_battle_attack")
	if _a_show_tutato_explain && explain_attack:
		match p_name:
			"SV/Attack_ATK_Charge_Right":
				start_action_button_blink()
				_cutscene("Tutato_Explain", "First_Battle_Attack_2", _CB_cutscene_completed, "Main", "Global")
	else:
		super(p_name)
