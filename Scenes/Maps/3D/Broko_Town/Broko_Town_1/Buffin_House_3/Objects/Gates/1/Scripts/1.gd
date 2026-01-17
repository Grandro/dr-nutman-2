extends Static3DObject
class_name ObjectGate1

signal opened()

@onready var _a_States: CompStates = get_node("States")
@onready var _a_Anims: CompAnims = get_node("Anims")

func _ready() -> void:
	super()
	_a_States.state_tmp_changed.connect(_on_States_state_tmp_changed)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func _on_States_state_tmp_changed(p_state_tmp: StringName) -> void:
	var anim_name: StringName = _a_Anims.get_current_animation()
	var adjust_speed_scale: bool = false
	if p_state_tmp == &"Open" && anim_name == &"Close":
		adjust_speed_scale = true
	elif p_state_tmp == &"Close" && anim_name == &"Open":
		adjust_speed_scale = true
	
	var speed_scale: float = 1.0
	if adjust_speed_scale:
		var anim_pos: float = _a_Anims.get_current_animation_position()
		var anim_length: float = _a_Anims.get_current_animation_length()
		var ratio: float = anim_pos / anim_length
		speed_scale = 1.0 / ratio
	_a_Anims.set_speed_scale(speed_scale)

func _on_Anims_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Open":
			_a_States.set_state(&"Opened")
			opened.emit()
		&"Close":
			_a_States.set_state(&"Closed")
