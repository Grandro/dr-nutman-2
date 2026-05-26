extends Node3D
class_name FWCompAudio3D

signal audio_free_finished(p_file_name: String)

var _a_Shared: GDScript = preload("uid://dapnwalft3wql")

var _a_shared: FWCompAudioShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.audio_free_finished.connect(_on_Shared_audio_free_finished)
	_a_shared.ready()

func init(_p_entities: Array[Node]) -> void:
	pass

func play(p_key: String, p_from: float = 0.0) -> void:
	_a_shared.play(p_key, p_from)

func stop(p_key: String) -> void:
	_a_shared.stop(p_key)

func set_stream(p_key: String, p_stream: AudioStream) -> void:
	_a_shared.set_stream(p_key, p_stream)

func set_volume(p_key: String, p_volume: float) -> void:
	_a_shared.set_volume(p_key, p_volume)

func set_pitch(p_key: String, p_pitch: float) -> void:
	_a_shared.set_pitch(p_key, p_pitch)

func set_bus(p_key: String, p_bus: StringName) -> void:
	_a_shared.set_bus(p_key, p_bus)

func set_max_distance(p_key: String, p_distance: float) -> void:
	_a_shared.set_max_distance(p_key, p_distance)

func set_attenuation(p_key: String, p_attenuation: float) -> void:
	_a_shared.set_attenuation(p_key, p_attenuation)

func get_save_data() -> Dictionary:
	return _a_shared.get_save_data()

func load_data(p_data: Dictionary) -> void:
	_a_shared.load_data(p_data)

func load_data_init() -> void:
	pass

func _on_Shared_audio_free_finished(p_file_name: String) -> void:
	audio_free_finished.emit(p_file_name)
