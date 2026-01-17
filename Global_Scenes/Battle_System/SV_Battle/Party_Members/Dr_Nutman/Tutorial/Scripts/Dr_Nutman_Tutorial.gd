extends SVPartyMember
class_name SVDrNutmanTutorial

@onready var _a_Action_Button: Sprite3D = get_node("Action_Button")
@onready var _a_Action_Button_Anims: AnimationPlayer = get_node("Action_Button/Anims")

func _ready() -> void:
	super()
	_a_Action_Button.hide()

func start_action_button_blink() -> void:
	_a_Action_Button_Anims.play(&"Blink")
	_a_Action_Button.show()

func stop_action_button_blink() -> void:
	_a_Action_Button_Anims.stop()
	_a_Action_Button.hide()

func _process_action_start() -> void:
	match _a_command:
		&"Flee": cutscene(&"Flee_Attempt_1", &"0", _CB_cutscene_completed)
		_: super()

func _CB_cutscene_completed(_p_process_type: StringName, p_key: StringName, p_entry_key: StringName) -> void:
	match p_key:
		&"Flee_Attempt_1":
			match p_entry_key:
				&"0":
					_emit_action_canceled()
