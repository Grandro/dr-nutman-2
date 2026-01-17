extends HBoxContainer
class_name StatsDisplayEntryStatEntry

@export var _e_key: StringName = &""
@export var _e_normal_color: Color = Color.WHITE
@export var _e_warning_color: Color = Color.ORANGE
@export var _e_critical_color: Color = Color.RED
@export var _e_time_per_number: float = 0.1

const _a_ICON_PATH: String = "res://Global_Resources/Sprites/Icons/Stats/%s.png"

@onready var _a_Icon: TextureRect = get_node("Icon")
@onready var _a_Value: Label = get_node("Value")

var _a_value: int = -1
var _a_max_value: int = -1

func _ready() -> void:
	var texture: Texture2D = load(_a_ICON_PATH % _e_key)
	_a_Icon.set_texture(texture)

func _update_text_color() -> void:
	var percent: float = float(_a_value) / _a_max_value
	if percent <= 0.2:
		_a_Value.set(&"theme_override_colors/font_color", _e_critical_color)
	elif percent <= 0.4:
		_a_Value.set(&"theme_override_colors/font_color", _e_warning_color)
	else:
		_a_Value.set(&"theme_override_colors/font_color", _e_normal_color)

func get_key() -> StringName:
	return _e_key

func set_value(p_value: int, p_anim: bool) -> void:
	if p_anim:
		var duration: float = (_a_value - p_value) * _e_time_per_number
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_method(_set_value_text, _a_value, p_value, duration)
	
	_a_value = p_value
	if !p_anim:
		_set_value_text(p_value)

func set_max_value(p_max_value: int) -> void:
	_a_max_value = p_max_value
	_update_text_color()

func _set_value_text(p_value: int) -> void:
	_a_Value.set_text(str(p_value))
	if _a_max_value != -1:
		_update_text_color()
