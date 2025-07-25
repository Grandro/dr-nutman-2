extends PanelContainer

signal select_pressed()

@export var _e_highlight_color: Color = Color(0.6, 0.6, 0.6)
@export var _e_normal_color: Color = Color.TRANSPARENT

@onready var _a_Select = get_node("Select")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)

func highlight(p_highlight):
	var style_box = get("theme_override_styles/panel")
	if p_highlight:
		style_box.set_bg_color(_e_highlight_color)
	else:
		style_box.set_bg_color(_e_normal_color)

func _on_Select_pressed():
	select_pressed.emit()
