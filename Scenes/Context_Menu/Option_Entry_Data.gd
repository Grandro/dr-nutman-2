extends Resource
class_name ContextMenuOptionEntryData

@export var _e_hsep: bool = false # If true, ignore all others
@export var _e_icon_texture: Texture2D = null
@export var _e_show_left: bool = true
@export var _e_show_right: bool = false
@export var _e_visible: bool = true
@export var _e_disabled: bool = false
@export var _e_options: Dictionary[StringName, ContextMenuOptionEntryData] = {} # Match key to entry data
@export var _e_options_order: Array[StringName] = []

func get_hsep() -> bool:
	return _e_hsep

func get_icon_texture() -> Texture2D:
	return _e_icon_texture

func get_show_left() -> bool:
	return _e_show_left

func get_show_right() -> bool:
	return _e_show_right

func set_visible(p_visible: bool) -> void:
	_e_visible = p_visible

func get_visible() -> bool:
	return _e_visible

func set_disabled(p_disabled: bool) -> void:
	_e_disabled = p_disabled

func get_disabled() -> bool:
	return _e_disabled

func set_options(p_options: Dictionary[StringName, ContextMenuOptionEntryData]) -> void:
	_e_options = p_options

func get_options() -> Dictionary[StringName, ContextMenuOptionEntryData]:
	return _e_options

func get_options_order() -> Array[StringName]:
	return _e_options_order
