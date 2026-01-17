extends CutsceneThreadBase
class_name CutsceneThreadPlayAudio

var _a_audio_type: StringName
var _a_type: StringName
var _a_stream_path: String
var _a_volume: float
var _a_pitch: float
var _a_wait_finish: bool
var _a_max_distance: float
var _a_object_key: StringName
var _a_point_selected: bool
var _a_point_pos: Variant # Vector

func _ready() -> void:
	super()
	if !_a_loads_data:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		_a_object_key = cutscene_system_si.get_option_value(_a_args[&"Object"])
		_a_audio_type = cutscene_system_si.get_option_value(_a_args[&"Audio_Type"])
		_a_type = cutscene_system_si.get_option_value(_a_args[&"Type"])
		_a_stream_path = cutscene_system_si.get_option_value(_a_args[&"Audio"])
		_a_volume = cutscene_system_si.get_option_value(_a_args[&"Volume"])
		_a_pitch = cutscene_system_si.get_option_value(_a_args[&"Pitch"])
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args[&"Wait_Finish"])
		_a_max_distance = cutscene_system_si.get_option_value(_a_args[&"Max_Distance"])
		_a_point_selected = _a_args[&"Point"][&"Selected"]
		
		var point: Variant = cutscene_system_si.get_option_value(_a_args[&"Point"])
		var grid_step: Variant = _a_args[&"Grid"][&"Step"]
		var grid_start: Variant = _a_args[&"Grid"][&"Start"]
		_a_point_pos = Global.grid_point_to_pos(point, grid_step, grid_start)
		_process_command()

func skip() -> void:
	super()
	
	_emit_completed()
	queue_free()

func _process_command() -> void:
	if _a_stream_path.is_empty():
		if !_a_skip:
			_emit_completed()
			queue_free()
		return
	
	var stream: AudioStream = load(_a_stream_path)
	match _a_type:
		&"Static": _process_command_static(stream)
		&"Object": _process_command_object(stream)
		&"Point": _process_command_point(stream)
	
	if !_a_wait_finish && !_a_skip:
		_emit_completed()
		queue_free()
	
	super()

func _process_command_static(p_stream: AudioStream) -> void:
	var audio_manager_si: Audio_Manager = Global.get_singleton(self, "Audio_Manager")
	match _a_audio_type:
		&"BGM":
			if _a_wait_finish:
				audio_manager_si.bgm_finished.connect(_on_Audio_Manager_bgm_finished)
			audio_manager_si.play_bgm(p_stream, _a_volume, _a_pitch)
		&"SFX":
			if _a_wait_finish:
				audio_manager_si.sfx_finished.connect(_on_Audio_Manager_sfx_finished)
			audio_manager_si.play_sfx(p_stream, _a_volume, _a_pitch)
		&"BGS":
			if _a_wait_finish:
				audio_manager_si.bgs_finished.connect(_on_Audio_Manager_bgs_finished)
			audio_manager_si.play_bgs(p_stream, _a_volume, _a_pitch)

func _process_command_object(p_stream: AudioStream) -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	_a_object = global_si.get_object(_a_object_key)
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	if _a_wait_finish:
		var audio_comp: Node = _a_object.comph().get_comp("Audio")
		audio_comp.audio_free_finished.connect(_on_Object_audio_free_finished.bind(_a_audio_type))
	_a_object.comph().call_comp("Audio", &"set_bus", [&"$Free", _a_audio_type])
	_a_object.comph().call_comp("Audio", &"set_max_distance", [&"$Free", _a_max_distance])
	_a_object.comph().call_comp("Audio", &"set_stream", [&"$Free", p_stream])
	_a_object.comph().call_comp("Audio", &"set_volume", [&"$Free", linear_to_db(_a_volume)])
	_a_object.comph().call_comp("Audio", &"set_pitch", [&"$Free", _a_pitch])
	_a_object.comph().call_comp("Audio", &"play", [&"$Free"])

func _process_command_point(p_stream: AudioStream) -> void:
	if !_a_point_selected:
		if !_a_skip:
			_emit_completed()
			queue_free()
		return
	
	var free_audio: Node = _a_curr_scene.get_free_audio()
	if _a_wait_finish:
		free_audio.finished.connect(_on_Free_Audio_finished.bind(free_audio))
	free_audio.set_global_position(_a_point_pos)
	free_audio.set_bus(_a_audio_type)
	free_audio.set_max_distance(_a_max_distance)
	free_audio.set_stream(p_stream)
	free_audio.set_volume_db(linear_to_db(_a_volume))
	free_audio.set_pitch_scale(_a_pitch)
	free_audio.play()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	var args: Dictionary = data[&"Args"]
	args[&"Stream_Path"] = _a_stream_path
	args[&"Audio_Type"] = _a_audio_type
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	
	var args: Dictionary = p_data[&"Args"]
	_a_stream_path = args[&"Stream_Path"]
	_a_audio_type = args[&"Audio_Type"]
	
	# Don't process command!
	# This is handled in Audio_Manager/Object/Free_Audio

func _on_Audio_Manager_bgm_finished(p_file_name: String) -> void:
	var file_name: String = _a_stream_path.get_file()
	if file_name == p_file_name && !_a_skip:
		_emit_completed()
		queue_free()

func _on_Audio_Manager_sfx_finished(p_file_name: String) -> void:
	var file_name: String = _a_stream_path.get_file()
	if file_name == p_file_name && !_a_skip:
		_emit_completed()
		queue_free()

func _on_Audio_Manager_bgs_finished(p_file_name: String) -> void:
	var file_name: String = _a_stream_path.get_file()
	if file_name == p_file_name && !_a_skip:
		_emit_completed()
		queue_free()

func _on_Object_audio_free_finished(p_file_name: String, p_audio_type: StringName) -> void:
	if _a_audio_type == p_audio_type:
		var file_name: String = _a_stream_path.get_file()
		if file_name == p_file_name && !_a_skip:
			_emit_completed()
			queue_free()

func _on_Free_Audio_finished(p_free_audio: Node) -> void:
	var audio_type: StringName = p_free_audio.get_bus()
	if _a_audio_type == audio_type:
		var file_name: String = _a_stream_path.get_file()
		var free_audio_stream: AudioStream = p_free_audio.get_stream()
		var free_audio_file_path: String = free_audio_stream.get_path()
		var free_audio_file_name: String = free_audio_file_path.get_file()
		if file_name == free_audio_file_name && !_a_skip:
			_emit_completed()
			queue_free()
