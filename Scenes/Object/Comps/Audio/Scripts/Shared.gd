extends ExtensionBase
class_name CompAudioShared

signal audio_free_finished(p_file_name: String)

var _a_Audio_Free: Node

func ready() -> void:
	_a_Audio_Free = _a_entity.get_node("$Free")
	
	_a_Audio_Free.finished.connect(_on_Audio_Free_finished)

func play(p_key: String, p_from: float) -> void:
	var instance: Node = _a_entity.get_node(p_key)
	instance.play(p_from)

func stop(p_key: String) -> void:
	var instance: Node = _a_entity.get_node(p_key)
	instance.stop()

func set_stream(p_key: String, p_stream: AudioStream) -> void:
	var instance: Node = _a_entity.get_node(p_key)
	instance.set_stream(p_stream)

func set_volume(p_key: String, p_volume: float) -> void:
	var instance: Node = _a_entity.get_node(p_key)
	instance.set_volume_db(p_volume)

func set_pitch(p_key: String, p_pitch: float) -> void:
	var instance: Node = _a_entity.get_node(p_key)
	instance.set_pitch_scale(p_pitch)

func set_bus(p_key: String, p_bus: StringName) -> void:
	var instance: Node = _a_entity.get_node(p_key)
	instance.set_bus(p_bus)

func set_max_distance(p_key: String, p_distance: float) -> void:
	var instance: Node = _a_entity.get_node(p_key)
	instance.set_max_distance(p_distance)

func set_attenuation(p_key: String, p_attenuation: float) -> void:
	var instance: Node = _a_entity.get_node(p_key)
	instance.set_attenuation(p_attenuation)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	for child: Node in _a_entity.get_children():
		var key: StringName = child.get_name()
		data[key] = child.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	for key: String in p_data:
		var instance: Node = _a_entity.get_node(key)
		instance.load_data(p_data[key])

func _on_Audio_Free_finished() -> void:
	var stream: AudioStream = _a_Audio_Free.get_stream()
	var file_path: String = stream.get_path()
	var file_name: String = file_path.get_file()
	audio_free_finished.emit(file_name)
