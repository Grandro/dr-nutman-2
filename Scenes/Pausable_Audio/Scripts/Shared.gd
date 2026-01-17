extends ExtensionBase
class_name PausableAudioShared

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	var playing: bool = _a_entity.is_playing()
	var stream_paused: bool = _a_entity.get_stream_paused()
	var stream_paused_: bool = _a_entity.get_stream_paused_()
	var stream: AudioStream = _a_entity.get_stream()
	var stream_path: String = ""
	if stream != null:
		stream_path = stream.get_path()
	data[&"Bus"] = _a_entity.get_bus()
	data[&"Volume"] = _a_entity.get_volume_db()
	data[&"Pitch"] = _a_entity.get_pitch_scale()
	data[&"Playing"] = playing || (stream_paused && !stream_paused_)
	data[&"Playback_Pos"] = _a_entity.get_playback_position()
	data[&"Stream_Path"] = stream_path
	
	return data

func load_data(p_data: Dictionary) -> void:
	var stream_path: String = p_data[&"Stream_Path"]
	var stream: AudioStream = null
	if !stream_path.is_empty():
		stream = load(stream_path)
	_a_entity.set_stream(stream)
	_a_entity.set_bus(p_data[&"Bus"])
	_a_entity.set_volume_db(p_data[&"Volume"])
	_a_entity.set_pitch_scale(p_data[&"Pitch"])
	if p_data[&"Playing"]:
		_a_entity.play(p_data[&"Playback_Pos"])
