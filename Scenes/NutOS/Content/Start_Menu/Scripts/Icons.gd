extends PanelContainer

signal settings_pressed()
signal power_option_selected(p_option)

@export var _e_expanded_color: Color = Color(0.19, 0.19, 0.19)
@export var _e_collapsed_color: Color = Color(0.1, 0.1, 0.1)

@onready var _a_Expand_Select = get_node("VBox/Expand/Select")
@onready var _a_Settings_Select = get_node("VBox/Settings/Select")
@onready var _a_Settings_Desc = get_node("VBox/Settings/HBox/Desc")
@onready var _a_Power_Select = get_node("VBox/Power/Select")
@onready var _a_Power_Desc = get_node("VBox/Power/HBox/Desc")
@onready var _a_Power_Options = get_node("Power_Options")

var _a_expanded = false

func _ready():
	_a_Expand_Select.pressed.connect(_on_Expand_Select_pressed)
	_a_Settings_Select.pressed.connect(_on_Settings_Select_pressed)
	_a_Power_Select.pressed.connect(_on_Power_Select_pressed)
	_a_Power_Options.option_selected.connect(_on_Power_Options_option_selected)
	
	_a_Power_Options.set_layer(1026)

func _on_Expand_Select_pressed():
	expand_collapse(!_a_expanded)

func expand_collapse(p_expand):
	var style_box = get("theme_override_styles/panel")
	if p_expand:
		style_box.set_bg_color(_e_expanded_color)
	else:
		style_box.set_bg_color(_e_collapsed_color)
	_a_Settings_Desc.set_visible(p_expand)
	_a_Power_Desc.set_visible(p_expand)
	
	_a_expanded = p_expand

func _on_Settings_Select_pressed():
	settings_pressed.emit()

func _on_Power_Select_pressed():
	var pos = get_global_mouse_position()
	_a_Power_Options.open(pos)

func _on_Power_Options_option_selected(p_option):
	power_option_selected.emit(p_option)
