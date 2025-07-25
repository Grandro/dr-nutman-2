extends "res://Global_Scenes/Battle_System/Battle_SV/Enemies/Scripts/Enemy_Battle.gd"

@onready var _a_Audio = get_node("Audio")
@onready var _a_Movement = get_node("Movement")
@onready var _a_Movement_Nav_Agent = get_node("Movement/Nav_Agent")
@onready var _a_Anims = get_node("Anims")
@onready var _a_States = get_node("States")
@onready var _a_Fire = get_node("Fire")
@onready var _a_Fire_Anims = get_node("Fire/Anims")
@onready var _a_Fever_Anims = get_node("Fever_Anims")

var _a_progress_si = null
var _a_show_tutato_explain = true

var _a_tween = null
var _a_battle_state = "" # Fever_Attack_Start/Fever_Attack_End
var _a_turn_count = 0

func _ready():
	_a_progress_si = Global.get_singleton(self, "Progress")
	_a_show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()
	
	super()
	_a_Movement_Nav_Agent.path_finished.connect(_on_Movement_Nav_Agent_path_finished)
	_a_Fire_Anims.animation_finished.connect(_on_Fire_anim_finished)
	
	set_process(false)
	_a_Fire.hide()

func _process(_p_delta):
	if position.x <= 20.5:
		_a_tween.pause()
		_cutscene("Tutato_Explain", "First_Battle_Dodge_2", _CB_cutscene_completed, "Main", "Global")
		
		set_process(false)

func process_action_start():
	match _a_turn_count:
		0, 1:
			# 0: Just feeling unwell
			# 1: Saying head feels hot
			_cutscene("Sick_Apprentice_Action_1", str(_a_turn_count), _CB_cutscene_completed)
		2:
			_fever_attack_start()
		3:
			_fever_attack_start()
		4:
			_a_Fever_Anims.play("No_Fever")
			_cutscene("Sick_Apprentice_Action_1", str(_a_turn_count), _CB_cutscene_completed)

func _fever_attack_start():
	_a_Fire_Anims.play("Start_Burn")
	_a_Fire.show()

func _fever_attack_slide():
	_a_target = _a_encounter.get_character("Dr_Nutman")
	
	_a_tween = create_tween()
	_a_tween.finished.connect(_on_Tween_finished.bind("position"))
	_a_tween.set_trans(Tween.TRANS_QUAD)
	_a_tween.set_ease(Tween.EASE_IN)
	_a_tween.tween_property(self, "position:x", -1.5, 3.0)
	
	var explain_dodge = _a_progress_si.call_object("Tutato", "get_explain_battle_dodge")
	if _a_show_tutato_explain && explain_dodge:
		set_process(true)
	else:
		_a_Hitbox.set_monitoring(true)
		attack_pm_started.emit(_a_target)

func _fever_attack_to_start():
	_a_battle_state = "Fever_Attack_End"
	attack_pm_finished.emit(_a_target)
	_a_Hitbox.set_monitoring(false)
	
	var tween = create_tween().set_parallel(true)
	tween.finished.connect(_on_Tween_finished.bind("rotation"))
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rotation_degrees:z", 0.0, 2.0)
	tween.tween_property(self, "position:y", 0.0, 2.0)
	
	var from = Vector3.ZERO
	match _a_turn_count:
		1: from = Vector3(40.0, 15.0, 10.0)
		2: from = Vector3(40.0, 13.0, 22.0)
		3: from = Vector3(40.0, 14.0, 30.0)
	var to = Vector3(25.0, 0.0, 19.0)
	tween.tween_property(self, "position", to, 2.0).from(from)

func _fever_attack_end():
	_a_turn_count += 1
	_emit_turn_completed()

func _on_Movement_Nav_Agent_path_finished():
	var state = _a_Movement.get_state()
	match state:
		"Recover_Knockback":
			_a_States.set_state("Idle")
			_a_Movement.reset_dir()
			_a_Anims.update_anim()

func _on_Fire_anim_finished(p_name):
	match p_name:
		"Start_Burn":
			_a_battle_state = "Fever_Attack_Start"
			_a_States.set_state_tmp("Stop")
			_a_Anims.update_anim()
			var tween = create_tween().set_parallel(true)
			tween.finished.connect(_on_Tween_finished.bind("rotation"))
			tween.set_trans(Tween.TRANS_BOUNCE)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rotation_degrees:z", -90.0, 2.0)
			tween.tween_property(self, "position:y", 0.5, 2.0)
		
		"End_Burn":
			_a_Fire.hide()
			if _a_turn_count == 1:
				# Says he has seen weird things
				_cutscene("Sick_Apprentice_Action_1", "3", _CB_cutscene_completed)
			else:
				_fever_attack_end()

func _on_Tween_finished(p_key):
	match p_key:
		"position":
			var explain_dodge = _a_progress_si.call_object("Tutato", "get_explain_battle_dodge")
			if _a_show_tutato_explain && explain_dodge:
				_cutscene("Tutato_Explain", "First_Battle_Dodge_3", _CB_cutscene_completed, "Main", "Global")
			else:
				_fever_attack_to_start()
		
		"rotation":
			match _a_battle_state:
				"Fever_Attack_Start":
					if _a_turn_count == 1:
						# Talking about dodging fever-attack
						_cutscene("Sick_Apprentice_Action_1", "2", _CB_cutscene_completed)
					else:
						_fever_attack_slide()
				
				"Fever_Attack_End":
					_a_States.set_state_tmp("Idle")
					_a_Anims.update_anim()
					_a_Fire_Anims.play("End_Burn")

func _on_Hitbox_body_entered(p_body):
	_a_Audio.play("Hit")
	super(p_body)

func _CB_cutscene_completed(_p_type, p_key, p_entry_key):
	match p_key:
		"Sick_Apprentice_Action_1":
			match p_entry_key:
				"0":
					_a_turn_count += 1
					_emit_turn_completed()
				"1":
					_fever_attack_start()
				"2":
					if _a_show_tutato_explain:
						_cutscene("Tutato_Explain", "First_Battle_Dodge_1", _CB_cutscene_completed, "Main", "Global")
					else:
						_fever_attack_slide()
				"3":
					_fever_attack_end()
				"4":
					_a_encounter.battle_end("Win")
		
		"Tutato_Explain":
			match p_entry_key:
				"First_Battle_Dodge_1":
					_fever_attack_slide()
				"First_Battle_Dodge_2":
					_a_tween.play()
					attack_pm_started.emit(_a_target)
				"First_Battle_Dodge_3":
					_a_progress_si.call_object("Tutato", "set_explain_battle_dodge", [false])
					_fever_attack_to_start()
