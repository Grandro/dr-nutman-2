extends CutsceneThreadBase
class_name CutsceneThreadShowPopup

var _a_object_key: StringName
var _a_type: StringName
var _a_wait_finish: bool
var _a_anim_pos: float
var _a_timer_time_left: float
var _a_anim: StringName

func _ready() -> void:
	super()
	if !_a_loads_data:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		_a_object_key = cutscene_system_si.get_option_value(_a_args[&"Object"])
		_a_type = cutscene_system_si.get_option_value(_a_args[&"Type"])
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args[&"Wait_Finish"])
		_process_command()

func skip() -> void:
	super()
	
	_a_object.comph().call_comp("Popup", &"reset")
	
	_emit_completed()
	queue_free()

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	_a_object = global_si.get_object(_a_object_key)
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	var popup_comp: Node = _a_object.comph().get_comp("Popup")
	popup_comp.finished.connect(_on_Object_popup_finished)
	
	if _a_timer_time_left == 0.0:
		if _a_anim == &"Fade_Out":
			popup_comp.play_anim(_a_anim)
		else:
			popup_comp.popup(_a_type, true)
		popup_comp.seek_anim(_a_anim_pos)
	else:
		popup_comp.start_timer(_a_timer_time_left)
	
	if !_a_wait_finish && !_a_skip && !_a_loads_data:
		_emit_completed()
	
	super()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	var args: Dictionary = data[&"Args"]
	args[&"Object"] = {}
	args[&"Object"][&"Value"] = _a_object_key
	args[&"Type"] = _a_type
	args[&"Wait_Finish"] = _a_wait_finish
	args[&"Anim_Pos"] = _a_object.comph().call_comp("Popup", &"get_anim_pos")
	args[&"Timer_Time_Left"] = _a_object.comph().call_comp("Popup", &"get_timer_time_left")
	args[&"Anim"] = _a_object.comph().call_comp("Popup", &"get_assigned_anim")
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	
	var args: Dictionary = p_data[&"Args"]
	_a_object_key = args[&"Object"][&"Value"]
	_a_type = args[&"Type"]
	_a_wait_finish = args[&"Wait_Finish"]
	_a_anim_pos = args[&"Anim_Pos"]
	_a_timer_time_left = args[&"Timer_Time_Left"]
	_a_anim = args[&"Anim"]
	
	_process_command()

func _on_Object_popup_finished() -> void:
	if !_a_skip:
		if _a_wait_finish:
			_emit_completed()
		queue_free()
