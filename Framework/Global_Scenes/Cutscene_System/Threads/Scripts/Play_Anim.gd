extends FWCutsceneThreadBase
class_name FWCutsceneThreadPlayAnim

var _a_object_key: StringName
var _a_keep_dir: bool
var _a_backwards: bool
var _a_speed: float
var _a_wait_finish: bool
var _a_anim_name: StringName

func _ready() -> void:
	super()
	if !_a_loads_data:
		var global_si: Global = Global.get_singleton(self, "Global")
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		_a_object_key = cutscene_system_si.get_option_value(_a_args[&"Object"])
		_a_keep_dir = cutscene_system_si.get_option_value(_a_args[&"Keep_Dir"])
		_a_backwards = cutscene_system_si.get_option_value(_a_args[&"Backwards"])
		_a_speed = cutscene_system_si.get_option_value(_a_args[&"Speed"])
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args[&"Wait_Finish"])
		_a_object = global_si.get_object(_a_object_key)
		if _a_keep_dir:
			var dir_vec: Variant = _a_object.comph().call_comp("Movement", &"get_dir_vec")
			var dir_name: StringName = Global.get_dir_vec_name(dir_vec)
			_a_anim_name = cutscene_system_si.get_option_value(_a_args[&"Anim_Keep_Dir"])
			_a_anim_name = "%s_%s" % [_a_anim_name, dir_name]
		else:
			_a_anim_name = cutscene_system_si.get_option_value(_a_args[&"Anim_All"])
		_process_command()

func skip() -> void:
	super()
	
	if _a_wait_finish:
		var anims_comp: FWCompAnims = _a_object.comph().get_comp("Anims")
		anims_comp.animation_finished.disconnect(_on_Object_anim_finished)
	
	if _a_backwards:
		# Jump to beginning of anim
		_a_object.comph().call_comp("Anims", &"seek_anim", [0.0])
	else:
		# Jump to end of anim
		var curr_anim: StringName = _a_object.comph().call_comp("Anims", &"get_current_animation")
		if curr_anim != &"":
			var anim: Animation = _a_object.comph().call_comp("Anims", &"get_animation", [curr_anim])
			var length: float = anim.get_length()
			_a_object.comph().call_comp("Anims", &"seek_anim", [length])
	
	queue_free()
	_emit_completed()

func _process_command() -> void:
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	_a_object.comph().call_comp("Anims", &"play_anim", [_a_anim_name, _a_speed, _a_backwards])
	
	var anim_split: PackedStringArray = _a_anim_name.split("_")
	var state: StringName = anim_split[0]
	if _a_object.comph().has_comp("States"):
		if _a_object.comph().call_comp("States", &"has_state", [state]):
			_a_object.comph().call_comp("States", &"set_state", [state])
	
	if _a_object.comph().has_comp("Movement"):
		if anim_split.size() > 1 && !_a_keep_dir:
			var dir_name: StringName = anim_split[-1]
			_a_object.comph().call_comp("Movement", &"set_dir_name", [dir_name])
	
	if _a_wait_finish:
		var anims_comp: FWCompAnims = _a_object.comph().get_comp("Anims")
		anims_comp.animation_finished.connect(_on_Object_anim_finished)
	elif !_a_skip:
		queue_free()
		_emit_completed()
	
	super()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	var args: Dictionary = data[&"Args"]
	args[&"Object"] = {}
	args[&"Object"][&"Value"] = _a_object_key
	args[&"Keep_Dir"] = _a_keep_dir
	args[&"Backwards"] = _a_backwards
	args[&"Speed"] = _a_speed
	args[&"Wait_Finish"] = _a_wait_finish
	args[&"Anim_Name"] = _a_anim_name
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	
	var args: Dictionary = p_data[&"Args"]
	_a_object_key = args[&"Object"][&"Value"]
	_a_keep_dir = args[&"Keep_Dir"]
	_a_backwards = args[&"Backwards"]
	_a_speed = args[&"Speed"]
	_a_wait_finish = args[&"Wait_Finish"]
	_a_anim_name = args[&"Anim_Name"]
	
	var global_si: Global = Global.get_singleton(self, "Global")
	_a_object = global_si.get_object(_a_object_key)
	
	_process_command()

func _on_Object_anim_finished(_p_name: StringName) -> void:
	if !_a_skip:
		queue_free()
		if _a_wait_finish:
			_emit_completed()
