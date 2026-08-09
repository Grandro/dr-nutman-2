extends FWExtensionBase
class_name FWMapBaseShared

var _a_Free_Camera: Node
var _a_Free_Audio: Node

var _a_BGM: FWAudioPlayback = null
var _a_BGS: Array[FWAudioPlayback] = []

func ready() -> void:
	_a_Free_Camera = _a_entity.get_node("Objects/$Free_Camera")
	_a_Free_Audio = _a_entity.get_node("Objects/$Free_Audio")

func _play_BGM() -> void:
	var audio_manager_si: Audio_Manager = Global.get_singleton(_a_entity, "Audio_Manager")
	if _a_BGM == null:
		audio_manager_si.flatten_bgm()
		return
	
	var stream: AudioStream = _a_BGM.get_stream()
	var volume: float = _a_BGM.get_volume()
	var pitch: float = _a_BGM.get_pitch()
	var from: float = _a_BGM.get_from()
	var player: FWPausableAudio = audio_manager_si.replace_bgm(stream, volume, pitch, from)
	audio_manager_si.flatten_bgm(player)

func _play_BGS() -> void:
	var audio_manager_si: Audio_Manager = Global.get_singleton(_a_entity, "Audio_Manager")
	var players: Array[AudioStreamPlayer] = []
	var size: int = _a_BGS.size()
	players.resize(size)
	for i: int in size:
		var BGS: FWAudioPlayback = _a_BGS[i]
		var stream: AudioStream = BGS.get_stream()
		var volume: float = BGS.get_volume()
		var pitch: float = BGS.get_pitch()
		var from: float = BGS.get_from()
		var player: AudioStreamPlayer = audio_manager_si.replace_bgs(stream, volume, pitch, from)
		players[i] = player
	audio_manager_si.flatten_bgs(players)

func get_free_camera() -> Node:
	return _a_Free_Camera

func get_free_audio() -> Node:
	return _a_Free_Audio

func set_BGM(p_BGM: FWAudioPlayback) -> void:
	_a_BGM = p_BGM

func set_BGS(p_BGS: Array[FWAudioPlayback]) -> void:
	_a_BGS = p_BGS

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	var global_si: Global = Global.get_singleton(_a_entity, "Global")
	var camera_limit: Dictionary[Side, float] = global_si.get_camera_limit()
	data[&"Camera_Limit"] = camera_limit.duplicate()
	
	return data

func load_data(p_map_data: Dictionary) -> void:
	var global_si: Global = Global.get_singleton(_a_entity, "Global")
	global_si.set_camera_limit(p_map_data[&"Curr_Scene"][&"Camera_Limit"])

func load_data_init() -> void:
	_play_BGM()
	_play_BGS()
