extends FWCutsceneThreadBase
class_name FWCutsceneThreadTween

var _a_object_key: StringName
var _a_comp_key: StringName
var _a_property: String
var _a_start_value: Variant
var _a_end_value: Variant
var _a_duration: float
var _a_elapsed_time: float
var _a_trans_type: Tween.TransitionType
var _a_ease_type: Tween.EaseType
var _a_interpolate: bool
var _a_wait_finish: bool

var _a_tween: Tween

func _ready() -> void:
	super()
	
	set_process(false)
	if !_a_loads_data:
		var global_si: Global = Global.get_singleton(self, "Global")
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		var trans_type: StringName = cutscene_system_si.get_option_value(_a_args[&"Trans_Type"])
		var ease_type: StringName = cutscene_system_si.get_option_value(_a_args[&"Ease_Type"])
		_a_object_key = cutscene_system_si.get_option_value(_a_args[&"Object"])
		_a_comp_key = cutscene_system_si.get_option_value(_a_args[&"Comp"])
		_a_property = cutscene_system_si.get_option_value(_a_args[&"Property"])
		_a_start_value = cutscene_system_si.get_option_value(_a_args[&"Start_Value"])
		_a_end_value = cutscene_system_si.get_option_value(_a_args[&"End_Value"])
		_a_duration = cutscene_system_si.get_option_value(_a_args[&"Duration"])
		_a_elapsed_time = 0.0
		_a_trans_type = global_si.convert_trans_type_key(trans_type)
		_a_ease_type = global_si.convert_ease_type_key(ease_type)
		_a_interpolate = cutscene_system_si.get_option_value(_a_args[&"Interpolate"])
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args[&"Wait_Finish"])
		_process_command()

func skip() -> void:
	super()
	if _a_tween != null:
		_a_tween.kill()
	
	_a_comp.set(_a_property, _a_end_value)
	
	queue_free()
	_emit_completed()

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	_a_object = global_si.get_object(_a_object_key)
	_a_comp = _a_object.comph().get_comp(_a_comp_key)
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	
	if _a_interpolate:
		_a_tween = create_tween()
		_a_tween.finished.connect(_on_Tween_finished)
		_a_tween.set_trans(_a_trans_type)
		_a_tween.set_ease(_a_ease_type)
		var tween_property: PropertyTweener = _a_tween.tween_property(_a_comp, _a_property, _a_end_value, _a_duration)
		if _a_start_value != null:
			tween_property.from(_a_start_value)
		_a_tween.custom_step(_a_elapsed_time)
		
		if !_a_wait_finish && !_a_skip && !_a_loads_data:
			_emit_completed()
	else:
		_a_comp.set(_a_property, _a_end_value)
		if !_a_skip:
			queue_free()
			_emit_completed()
	
	super()

func get_save_data() -> Dictionary:
	_add_revert_property(_a_comp, _a_object_key, _a_comp_key, _a_property)
	
	var data: Dictionary = super()
	var args: Dictionary = data[&"Args"]
	args[&"Object"] = {}
	args[&"Object"][&"Value"] = _a_object_key
	args[&"Comp"] = _a_comp_key
	args[&"Property"] = _a_property
	args[&"End_Value"] = _a_end_value
	args[&"Interpolate"] = _a_interpolate
	args[&"Duration"] = _a_duration
	args[&"Elapsed_Time"] = _a_tween.get_total_elapsed_time()
	args[&"Trans_Type"] = _a_trans_type
	args[&"Ease_Type"] = _a_ease_type
	args[&"Start_Value"] = _a_start_value
	args[&"Wait_Finish"] = _a_wait_finish
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	
	var args: Dictionary = p_data[&"Args"]
	_a_object_key = args[&"Object"][&"Value"]
	_a_comp_key = args[&"Comp"]
	_a_property = args[&"Property"]
	_a_end_value = args[&"End_Value"]
	_a_interpolate = args[&"Interpolate"]
	_a_duration = args[&"Duration"]
	_a_elapsed_time = args[&"Elapsed_Time"]
	_a_trans_type = args[&"Trans_Type"]
	_a_ease_type = args[&"Ease_Type"]
	_a_start_value = args[&"Start_Value"]
	_a_wait_finish = args[&"Wait_Finish"]
	
	_process_command()

func _on_Tween_finished() -> void:
	if !_a_skip:
		queue_free()
		if _a_wait_finish:
			_emit_completed()
