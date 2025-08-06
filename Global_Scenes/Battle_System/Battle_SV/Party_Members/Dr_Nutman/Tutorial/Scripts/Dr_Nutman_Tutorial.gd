extends "res://Global_Scenes/Battle_System/Battle_SV/Party_Members/Scripts/Party_Member_Battle.gd"

@onready var _a_Action_Button = get_node("Action_Button")
@onready var _a_Action_Button_Anims = get_node("Action_Button/Anims")

func _ready():
	super()
	_a_Action_Button.hide()

func start_action_button_blink():
	_a_Action_Button_Anims.play("Blink")
	_a_Action_Button.show()

func stop_action_button_blink():
	_a_Action_Button_Anims.stop()
	_a_Action_Button.hide()

func _process_action_start():
	match _a_command:
		"Flee": cutscene("Flee_Attempt_1", "0", _CB_cutscene_completed)
		_: super()

func _CB_cutscene_completed(_p_process_type, p_key, p_entry_key):
	match p_key:
		"Flee_Attempt_1":
			match p_entry_key:
				"0":
					_emit_action_canceled()
