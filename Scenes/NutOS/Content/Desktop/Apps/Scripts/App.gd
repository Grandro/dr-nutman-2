extends FWWindowBase
class_name NutOSContentDesktopApp

const _a_TITLE_LOC_ID: String = "NUTOS_APP_%s"

signal closed(p_save_data: Dictionary)
signal option_selected(p_key: StringName, p_option: StringName, p_value: Variant) # App option changed e.g. Keyboard_Customizer color

var _a_key: StringName
var _a_init_pos: Vector2i = Vector2i.ZERO
var _a_init_size: Vector2i = Vector2i.ZERO

func _ready() -> void:
	close_requested.connect(_on_close_requested)
	
	_a_init_pos = get_position()
	_a_init_size = get_size()
	
	var title_loc_id: StringName = _a_TITLE_LOC_ID % _a_key.to_upper()
	set_title(tr(title_loc_id))

func open(_p_save_data: Dictionary) -> void:
	pass

func _close() -> void:
	set_position(_a_init_pos)
	set_size(_a_init_size)
	
	var save_data: Dictionary = get_save_data(true)
	closed.emit(save_data)

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key

func get_save_data(_p_closed: bool) -> Dictionary:
	return {}

func _on_close_requested() -> void:
	pass
