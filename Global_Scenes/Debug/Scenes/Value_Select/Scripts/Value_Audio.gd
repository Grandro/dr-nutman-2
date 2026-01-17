extends DebugValueSelect
class_name DebugValueSelectAudio

signal started()
signal paused()
signal stopped()
signal seeked(p_pos: float)

@onready var _a_Value: DebugAudioSelect = get_node("Value")

func _ready() -> void:
	super()
	_a_Value.started.connect(_on_Value_started)
	_a_Value.paused.connect(_on_Value_paused)
	_a_Value.stopped.connect(_on_Value_stopped)
	_a_Value.seeked.connect(_on_Value_seeked)

func stop_audio() -> void:
	_a_Value.stop_audio()

func set_bus(p_bus: StringName) -> void:
	_a_Value.set_bus(p_bus)

func set_volume_db(p_volume_db: float) -> void:
	_a_Value.set_volume_db(p_volume_db)

func set_pitch_scale(p_pitch_scale: float) -> void:
	_a_Value.set_pitch_scale(p_pitch_scale)

func is_audio_playing() -> bool:
	return _a_Value.is_audio_playing()

func get_audio_stream() -> AudioStream:
	return _a_Value.get_audio_stream()

func get_audio_playback_position() -> float:
	return _a_Value.get_audio_playback_position()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = _a_Value.get_stream_path()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Value.set_audio_stream(p_data[&"Value"])

func load_data_init() -> void:
	_a_Value.set_audio_stream("")

func _on_Var_Select_active_toggled(p_toggled: bool) -> void:
	_a_Value.set_disabled(p_toggled)

func _on_Value_started() -> void:
	started.emit()

func _on_Value_paused() -> void:
	paused.emit()

func _on_Value_stopped() -> void:
	stopped.emit()

func _on_Value_seeked(p_pos: float) -> void:
	seeked.emit(p_pos)
