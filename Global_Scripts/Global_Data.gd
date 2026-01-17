extends Node

signal keyboard_layout_changed(p_keyboard_layout: StringName)
signal fav_color_changed(p_fav_color: Color)

const _a_SAVE_PATH: String = "user://Saves/Global.save"

var _a_data: Dictionary = {} # Globally Saved Data

func _ready() -> void:
	_load_global_data()

func apply_options_audio_volume_master(p_volume: float) -> void:
	var db_volume: float = linear_to_db(p_volume)
	var bus_idx: int = AudioServer.get_bus_index(&"Master")
	AudioServer.set_bus_volume_db(bus_idx, db_volume)

func apply_options_audio_volume_BGM(p_volume: float) -> void:
	var db_volume: float = linear_to_db(p_volume)
	var bus_idx: int = AudioServer.get_bus_index(&"BGM")
	AudioServer.set_bus_volume_db(bus_idx, db_volume)

func apply_options_audio_volume_BGS(p_volume: float) -> void:
	var db_volume: float = linear_to_db(p_volume)
	var bus_idx: int = AudioServer.get_bus_index(&"BGS")
	AudioServer.set_bus_volume_db(bus_idx, db_volume)

func apply_options_audio_volume_SFX(p_volume: float) -> void:
	var db_volume: float = linear_to_db(p_volume)
	var bus_idx: int = AudioServer.get_bus_index(&"SFX")
	AudioServer.set_bus_volume_db(bus_idx, db_volume)

func apply_options_video_vsync_mode(p_vsync_mode: StringName) -> void:
	match p_vsync_mode:
		&"Disabled": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		&"Enabled": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		&"Adaptive": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		&"Mailbox": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)

func apply_options_video_window_size(p_window_size: StringName) -> void:
	match p_window_size:
		&"240x135": DisplayServer.window_set_size(Vector2i(240, 135))
		&"480x270": DisplayServer.window_set_size(Vector2i(480, 270))
		&"720x405": DisplayServer.window_set_size(Vector2i(720, 405))
		&"960x540": DisplayServer.window_set_size(Vector2i(960, 540))
		&"1280x720": DisplayServer.window_set_size(Vector2i(1280, 720))
		&"1600x900": DisplayServer.window_set_size(Vector2i(1600, 900))
		&"1920x1080": DisplayServer.window_set_size(Vector2i(1920, 1080))
		&"2560x1440": DisplayServer.window_set_size(Vector2i(2560, 1440))
		&"3840x2160": DisplayServer.window_set_size(Vector2i(3840, 2160))

func apply_options_video_window_mode(p_window_mode: StringName) -> void:
	match p_window_mode:
		&"Windowed": 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		&"Fullscreen": 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		&"Exclusive_Fullscreen": 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func apply_options_controls_keyboard_layout(p_keyboard_layout: StringName) -> void:
	keyboard_layout_changed.emit(p_keyboard_layout)

func apply_locale(p_locale: String) -> void:
	TranslationServer.set_locale(p_locale)

func apply_fav_color(p_fav_color: Color) -> void:
	fav_color_changed.emit(p_fav_color)

func _apply() -> void:
	_apply_options(_a_data[&"Options"])
	apply_locale(_a_data[&"Locale"])
	apply_fav_color(_a_data[&"Fav_Color"][&"Selected"])

func _apply_options(p_data: Dictionary) -> void:
	_apply_options_audio(p_data[&"Audio"])
	_apply_options_video(p_data[&"Video"])

func _apply_options_audio(p_data: Dictionary) -> void:
	_apply_options_audio_volume(p_data[&"Volume"])

func _apply_options_audio_volume(p_data: Dictionary) -> void:
	apply_options_audio_volume_master(p_data[&"Master"][&"Value"])
	apply_options_audio_volume_BGM(p_data[&"BGM"][&"Value"])
	apply_options_audio_volume_BGS(p_data[&"BGS"][&"Value"])
	apply_options_audio_volume_SFX(p_data[&"SFX"][&"Value"])

func _apply_options_video(p_data: Dictionary) -> void:
	apply_options_video_vsync_mode(p_data[&"VSync_Mode"][&"Value"])
	apply_options_video_window_size(p_data[&"Window_Size"][&"Value"])
	apply_options_video_window_mode(p_data[&"Window_Mode"][&"Value"])

func _validate() -> void:
	var save_file_idx: int = _a_data[&"Save_File_Idx"]
	if save_file_idx != -1:
		var save_path: String = Global.get_save_path() % str(save_file_idx)
		if !FileAccess.file_exists(save_path):
			_a_data[&"Save_File_Idx"] = -1
	
	var version: StringName = _a_data[&"Version"]
	var curr_version: StringName = Global.get_version()
	while version != curr_version:
		match version:
			&"0.0.6":
				_validate_006_to_007()
				version = &"0.0.7"
	
	_a_data[&"Version"] = curr_version

func _validate_006_to_007() -> void:
	pass

func _get_init_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Options"] = _get_init_data_options()
	data[&"Locale"] = _get_init_data_locale()
	data[&"Fav_Color"] = _get_init_data_fav_color()
	data[&"Version"] = Global.get_version()
	data[&"Save_File_Idx"] = -1
	
	return data

func _get_init_data_options() -> Dictionary:
	var data: Dictionary = {}
	data[&"Audio"] = _get_init_data_options_audio()
	data[&"Video"] = _get_init_data_options_video()
	data[&"Gameplay"] = _get_init_data_options_gameplay()
	data[&"Controls"] = _get_init_data_options_controls()
	
	return data

func _get_init_data_options_audio() -> Dictionary:
	var data: Dictionary = {}
	data[&"Volume"] = _get_init_data_options_audio_volume()
	
	return data

func _get_init_data_options_audio_volume() -> Dictionary:
	var data: Dictionary = {}
	data[&"Master"] = {}
	data[&"Master"][&"Value"] = 0.5
	data[&"BGM"] = {}
	data[&"BGM"][&"Value"] = 1.0
	data[&"BGS"] = {}
	data[&"BGS"][&"Value"] = 1.0
	data[&"SFX"] = {}
	data[&"SFX"][&"Value"] = 1.0
	
	return data

func _get_init_data_options_video() -> Dictionary:
	var data: Dictionary = {}
	data[&"VSync_Mode"] = {}
	data[&"VSync_Mode"][&"Value"] = &"Disabled"
	data[&"Window_Size"] = {}
	data[&"Window_Size"][&"Value"] = &"1280x720"
	data[&"Window_Mode"] = {}
	data[&"Window_Mode"][&"Value"] = &"Windowed"
	
	return data

func _get_init_data_options_gameplay() -> Dictionary:
	var data: Dictionary = {}
	data[&"Show_Tutato_Explain"] = {}
	data[&"Show_Tutato_Explain"][&"Value"] = true
	
	return data

func _get_init_data_options_controls() -> Dictionary:
	var data: Dictionary = {}
	data[&"Keyboard_Layout"] = {}
	
	var keyboard_layout: StringName = &"QWERTY"
	var locale: String = TranslationServer.get_locale()
	if "de" in locale:
		keyboard_layout = &"QWERTZ"
	data[&"Keyboard_Layout"][&"Value"] = keyboard_layout
	
	return data

func _get_init_data_locale() -> String:
	var loaded_locales: PackedStringArray = TranslationServer.get_loaded_locales()
	var locale: String = OS.get_locale_language()
	if !loaded_locales.has(locale):
		locale = "en"
	
	return locale

func _get_init_data_fav_color() -> Dictionary:
	var data: Dictionary = {}
	data[&"Selected"] = Color8(138, 60, 246)
	data[&"Prev"] = [Color8(138, 60, 246)]
	
	return data

func set_entry_data(p_key: StringName, p_data: Dictionary) -> void:
	_a_data[p_key] = p_data

func get_entry_data(p_key: StringName) -> Dictionary:
	return _a_data[p_key]

func set_options_audio_volume_master(p_volume: float) -> void:
	_a_data[&"Options"][&"Audio"][&"Volume"][&"Master"][&"Value"] = p_volume
	apply_options_audio_volume_master(p_volume)

func set_options_audio_volume_BGM(p_volume: float) -> void:
	_a_data[&"Options"][&"Audio"][&"Volume"][&"BGM"][&"Value"] = p_volume
	apply_options_audio_volume_BGM(p_volume)

func set_options_audio_volume_BGS(p_volume: float) -> void:
	_a_data[&"Options"][&"Audio"][&"Volume"][&"BGS"][&"Value"] = p_volume
	apply_options_audio_volume_BGS(p_volume)

func set_options_audio_volume_SFX(p_volume: float) -> void:
	_a_data[&"Options"][&"Audio"][&"Volume"][&"SFX"][&"Value"] = p_volume
	apply_options_audio_volume_SFX(p_volume)

func set_options_video_vsync_mode(p_vsync_mode: StringName) -> void:
	_a_data[&"Options"][&"Video"][&"VSync_Mode"][&"Value"] = p_vsync_mode
	apply_options_video_vsync_mode(p_vsync_mode)

func set_options_video_window_size(p_window_size: StringName) -> void:
	_a_data[&"Options"][&"Video"][&"Window_Size"][&"Value"] = p_window_size
	apply_options_video_window_size(p_window_size)

func set_options_video_window_mode(p_window_mode: StringName) -> void:
	_a_data[&"Options"][&"Video"][&"Window_Mode"][&"Value"] = p_window_mode
	apply_options_video_window_mode(p_window_mode)

func set_options_gameplay_show_tutato_explain(p_show_tutato_explain: bool) -> void:
	_a_data[&"Options"][&"Gameplay"][&"Show_Tutato_Explain"][&"Value"] = p_show_tutato_explain

func get_options_gameplay_show_tutato_explain() -> bool:
	return _a_data[&"Options"][&"Gameplay"][&"Show_Tutato_Explain"][&"Value"]

func set_options_controls_keyboard_layout(p_keyboard_layout: StringName) -> void:
	_a_data[&"Options"][&"Controls"][&"Keyboard_Layout"][&"Value"] = p_keyboard_layout
	apply_options_controls_keyboard_layout(p_keyboard_layout)

func get_options_controls_keyboard_layout() -> StringName:
	return _a_data[&"Options"][&"Controls"][&"Keyboard_Layout"][&"Value"]

func set_locale(p_locale: String) -> void:
	_a_data[&"Locale"] = p_locale
	apply_locale(p_locale)

func get_locale() -> String:
	return _a_data[&"Locale"]

func set_fav_color(p_fav_color: Color) -> void:
	_a_data[&"Fav_Color"][&"Selected"] = p_fav_color
	apply_fav_color(p_fav_color)

func get_fav_color() -> Color:
	return _a_data[&"Fav_Color"][&"Selected"]

func set_save_file_idx(p_save_file_idx: int) -> void:
	_a_data[&"Save_File_Idx"] = p_save_file_idx

func get_save_file_idx() -> int:
	return _a_data[&"Save_File_Idx"]

func save_data() -> void:
	Data_Parser.write_var_data(_a_SAVE_PATH, _a_data)

func _load_global_data() -> void:
	if FileAccess.file_exists(_a_SAVE_PATH):
		_a_data = Data_Parser.load_var_data(_a_SAVE_PATH)
		_validate()
	else:
		_a_data = _get_init_data()
	
	_apply()
