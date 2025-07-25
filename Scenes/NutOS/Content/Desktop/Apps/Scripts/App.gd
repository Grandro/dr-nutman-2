extends "res://Scenes/Window/Scripts/Window_Base.gd"

const _a_TITLE_LOC_ID = "NUTOS_APP_%s"

signal closed(p_save_data)
signal option_selected(p_key, p_option, p_value) # App option changed e.g. Keyboard_Customizer color

var _a_key = ""
var _a_init_pos = Vector2i.ZERO
var _a_init_size = Vector2i.ZERO

func _ready():
	close_requested.connect(_on_close_requested)
	
	_a_init_pos = get_position()
	_a_init_size = get_size()
	
	var title_loc_id = _a_TITLE_LOC_ID % _a_key.to_upper()
	set_title(tr(title_loc_id))

func open(_p_save_data):
	pass

func _close():
	set_position(_a_init_pos)
	set_size(_a_init_size)
	
	var save_data = get_save_data(true)
	closed.emit(save_data)

func set_key(p_key):
	_a_key = p_key

func get_key():
	return _a_key

func get_save_data(_p_closed):
	return {}

func _on_close_requested():
	pass
