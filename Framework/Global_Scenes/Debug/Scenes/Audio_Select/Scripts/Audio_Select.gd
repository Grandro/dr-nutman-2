extends HBoxContainer
class_name FWDebugAudioSelect

signal started()
signal paused()
signal stopped()
signal seeked(p_pos: float)
signal path_changed(p_path: String)

const _a_SPRITES_PATH: String = "res://Global_Resources/Sprites/UI/%s.png"

enum _a_STATES {PLAY, PAUSE}

@export var _e_access: FileDialog.Access = FileDialog.ACCESS_FILESYSTEM
@export_dir var _e_dir_path: String = ""
@export var _e_filters: PackedStringArray = PackedStringArray(["*.wav", "*.ogg"])
@export_enum("Master", "BGM", "BGS", "SFX") var _e_bus: String = "BGM"

@onready var _a_Play: TextureButton = get_node("HBox/Play")
@onready var _a_Stop: TextureButton = get_node("HBox/Stop")
@onready var _a_Revert: TextureButton = get_node("Main/HBox/Revert")
@onready var _a_Revert_Anims: AnimationPlayer = get_node("Main/HBox/Revert/Anims")
@onready var _a_Path_Text: Label = get_node("Main/HBox/Path/Value")
@onready var _a_Progress: ProgressBar = get_node("Main/Progress")
@onready var _a_Time_Text: Label = get_node("Main/Options/Time")
@onready var _a_Select: Button = get_node("Select")
@onready var _a_File: FileDialog = get_node("File")
@onready var _a_Audio: AudioStreamPlayer = get_node("Audio")

var _a_path: String = ""
var _a_is_valid_stream: bool = false
var _a_last_pos: float = 0.0
var _a_stream_length: float = 0.0

func _ready() -> void:
	_a_Play.pressed.connect(_on_Play_pressed)
	_a_Stop.pressed.connect(_on_Stop_pressed)
	_a_Revert.pressed.connect(_on_Revert_pressed)
	_a_Progress.gui_input.connect(_on_Progress_gui_input)
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_File.file_selected.connect(_on_file_selected)
	_a_Audio.finished.connect(_on_Audio_finished)
	
	_a_Play.set_disabled(true)
	_a_Stop.set_disabled(true)
	set_process(false)
	
	_a_File.set_access(_e_access)
	_a_File.set_filters(_e_filters)
	_a_Audio.set_bus(_e_bus)

func _process(_p_delta: float) -> void:
	_a_last_pos = _a_Audio.get_playback_position()
	_update_time_text()
	_update_progress()

func hide_file() -> void:
	_a_File.hide()

func stop_audio() -> void:
	_a_Audio.stop()

func _reset_audio() -> void:
	set_process(false)
	_a_Audio.stop()
	_a_last_pos = 0.0
	_set_play_pause_textures(_a_STATES.PLAY)
	_update_time_text()
	_update_progress()

func _update_time_text() -> void:
	var curr: String = _seconds_to_time(int(_a_last_pos))
	var length: String = _seconds_to_time(int(_a_stream_length))
	var text: String = "%s - %s" % [curr, length]
	_a_Time_Text.set_text(text)

func _update_progress() -> void:
	var percent: float = 0.0
	if _a_stream_length > 0.0:
		percent = _a_last_pos / _a_stream_length * 100.0
	_a_Progress.set_value(percent)

func _seconds_to_time(p_seconds: int) -> String:
	var minutes: int = int(p_seconds / 60.0)
	p_seconds -= minutes * 60
	
	var padded_minutes: String = str(minutes).pad_zeros(2)
	var padded_seconds: String = str(p_seconds).pad_zeros(2)
	var time: String = "%s:%s" % [padded_minutes, padded_seconds]
	
	return time

func _set_path_text(p_text: String) -> void:
	_a_Path_Text.set_text(p_text)

func _set_play_pause_textures(p_state: _a_STATES) -> void:
	match p_state:
		_a_STATES.PLAY:
			var normal: Texture2D = load(_a_SPRITES_PATH % "Play_Normal")
			var disabled: Texture2D = load(_a_SPRITES_PATH % "Play_Disabled")
			_a_Play.set_texture_normal(normal)
			_a_Play.set_texture_disabled(disabled)
		_a_STATES.PAUSE:
			var normal: Texture2D = load(_a_SPRITES_PATH % "Pause_Normal")
			_a_Play.set_texture_normal(normal)
			_a_Play.set_texture_disabled(null)

func set_audio_stream(p_path: String) -> void:
	var stream: AudioStream
	var path_empty: bool = p_path.is_empty()
	if path_empty:
		_a_File.set_current_file("")
		_set_path_text("NONE")
		_a_stream_length = 0.0
	elif p_path.begins_with("user://"):
		var extension: String = p_path.get_extension()
		match extension:
			"ogg": stream = Data_Parser.load_ogg_stream(p_path)
			"wav": stream = Data_Parser.load_wav_stream(p_path)
	else:
		stream = load(p_path)
	
	_a_Audio.set_stream(stream)
	_a_Play.set_disabled(path_empty)
	_a_Stop.set_disabled(path_empty)
	_a_path = p_path
	_a_is_valid_stream = !path_empty
	path_changed.emit(p_path)
	
	if path_empty:
		_reset_audio()
		return
	
	_a_File.set_current_path(p_path)
	_set_path_text(p_path)
	_a_stream_length = stream.get_length()
	_reset_audio()

func set_volume_db(p_volume_db: float) -> void:
	_a_Audio.set_volume_db(p_volume_db)

func set_pitch_scale(p_pitch_scale: float) -> void:
	_a_Audio.set_pitch_scale(p_pitch_scale)

func set_bus(p_bus: StringName) -> void:
	_a_Audio.set_bus(p_bus)
	_e_bus = p_bus

func set_disabled(p_disabled: bool) -> void:
	var path_empty: bool = _a_path.is_empty()
	_a_Play.set_disabled(p_disabled || !path_empty)
	_a_Stop.set_disabled(p_disabled || !path_empty)
	_a_Revert.set_disabled(p_disabled)
	_a_Select.set_disabled(p_disabled)

func get_audio_stream() -> AudioStream:
	return _a_Audio.get_stream()

func is_audio_playing() -> bool:
	return _a_Audio.is_playing()

func get_audio_playback_position() -> float:
	return _a_Audio.get_playback_position()

func get_stream_path() -> String:
	var stream_path: String = ""
	var stream: AudioStream = _a_Audio.get_stream()
	if stream != null:
		stream_path = stream.get_path()
	
	return stream_path

func _on_Play_pressed() -> void:
	if _a_Audio.is_playing():
		_a_Audio.stop()
		set_process(false)
		_set_play_pause_textures(_a_STATES.PLAY)
		paused.emit()
	else:
		_a_Audio.play(_a_last_pos)
		set_process(true)
		_set_play_pause_textures(_a_STATES.PAUSE)
		started.emit()

func _on_Stop_pressed() -> void:
	_reset_audio()
	stopped.emit()

func _on_Revert_pressed() -> void:
	_a_Revert_Anims.play(&"Spin")
	if !_a_path.is_empty():
		set_audio_stream("")
		stopped.emit()

func _on_Progress_gui_input(p_event: InputEvent) -> void:
	if !_a_is_valid_stream:
		return
	
	if p_event.is_action(&"Mouse_Left"):
		if p_event.is_pressed():
			var x: float = p_event.get_position().x
			var width: float = _a_Progress.get_size().x
			var ratio: float = x / width
			_a_last_pos = ratio * _a_stream_length
			_a_Audio.seek(_a_last_pos)
			seeked.emit(_a_last_pos)
			
			if !_a_Audio.is_playing():
				_update_time_text()
				_update_progress()

func _on_Select_pressed() -> void:
	_a_File.set_current_dir(_e_dir_path)
	_a_File.popup_centered(Vector2(480, 660))

func _on_file_selected(p_path: String) -> void:
	set_audio_stream(p_path)
	if _a_Audio.is_playing():
		stopped.emit()

func _on_Audio_finished() -> void:
	var pos: float = _a_Audio.get_playback_position()
	var round_pos: float = snapped(pos, 0.001)
	var round_length: float = snapped(_a_stream_length, 0.001)
	
	set_process(false)
	if round_pos == round_length:
		_reset_audio()
	
	stopped.emit()
