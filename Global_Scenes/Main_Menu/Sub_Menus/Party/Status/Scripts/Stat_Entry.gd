extends HBoxContainer
class_name MainMenuSubMenuPartyStatusStatEntry

@export var _e_key: StringName = &""
@export var _e_max_key: StringName = &""

const _a_ICON_PATH: String = "res://Global_Resources/Sprites/Icons/Stats/%s.png"

@onready var _a_Icon: TextureRect = get_node("Margin/Margin/HBox/Icon")
@onready var _a_Desc: Label = get_node("Margin/Margin/HBox/Desc")
@onready var _a_Value_Curr: Label = get_node("Value/Curr")
@onready var _a_Value_Slash: Label = get_node("Value/Slash")
@onready var _a_Value_Max: Label = get_node("Value/Max")

func _ready() -> void:
	var texture: Texture2D = load(_a_ICON_PATH % _e_key)
	_a_Icon.set_texture(texture)
	_a_Desc.set_text(_e_key)

func hide_max_value() -> void:
	_a_Value_Slash.hide()
	_a_Value_Max.hide()

func get_key() -> StringName:
	return _e_key

func get_max_key() -> StringName:
	return _e_max_key

func set_curr_value(p_value: int) -> void:
	_a_Value_Curr.set_text(str(p_value))

func set_max_value(p_value: int) -> void:
	_a_Value_Max.set_text(str(p_value))
