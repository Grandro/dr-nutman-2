extends Control
class_name MiniGameBase

signal closed()

@export var _e_BGM: AudioStream = preload("res://Global_Resources/Audio/BGM/Color_Selection.ogg")
@export var _e_in_nutOS: bool = false

@onready var _a_Intro: MiniGameBaseIntro = get_node("Canvas/Intro")

var _a_game_play = null

func _ready() -> void:
	_a_game_play = get_node("Game_Play")
	
	_a_Intro.proceed_pressed.connect(_on_Intro_proceed_pressed)
	_a_game_play.finished.connect(_on_Game_Play_finished)
	
	hide()

func open() -> void:
	var audio_manager_si: Audio_Manager = Global.get_singleton(self, "Audio_Manager")
	audio_manager_si.play_bgm(_e_BGM)
	
	_a_Intro.open()
	show()

func close() -> void:
	var audio_manager_si: Audio_Manager = Global.get_singleton(self, "Audio_Manager")
	var bgm_path: String = _e_BGM.get_path()
	var bgm_file_name: String = bgm_path.get_file()
	audio_manager_si.stop_bgm(bgm_file_name)
	
	hide()
	closed.emit()

func _on_Intro_proceed_pressed() -> void:
	_a_game_play.open()

func _on_Game_Play_finished() -> void:
	close()
