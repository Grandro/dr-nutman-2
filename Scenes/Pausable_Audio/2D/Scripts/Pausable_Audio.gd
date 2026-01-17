extends AudioStreamPlayer2D
class_name PausableAudio2D

var _a_Shared: GDScript = preload("res://Scenes/Pausable_Audio/Scripts/Shared.gd")

var _a_shared: PausableAudioShared

var _a_stream_paused: bool = false

func _ready() -> void:
	_a_shared = _a_Shared.new(self)

func _notification(p_what: int) -> void:
	match p_what:
		NOTIFICATION_UNPAUSED:
			stream_paused = _a_stream_paused

func set_stream_paused_(p_paused: bool) -> void:
	stream_paused = p_paused
	_a_stream_paused = p_paused

func get_stream_paused_() -> bool:
	return _a_stream_paused

func get_save_data() -> Dictionary:
	var data: Dictionary = _a_shared.get_save_data()
	data[&"Transform"] = get_transform()
	data[&"Max_Distance"] = get_max_distance()
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_shared.load_data(p_data)
	set_transform(p_data[&"Transform"])
	set_max_distance(p_data[&"Max_Distance"])

func load_data_init() -> void:
	pass
