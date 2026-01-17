extends MarginContainer
class_name DebugCommandEditorArgEntry

const _a_FOCUS_COLOR: Color = Color.WHITE
const _a_NORMAL_COLOR: Color = Color.TRANSPARENT

@onready var _a_Outlines: PanelContainer = get_node("Outlines")
@onready var _a_HBox: HBoxContainer = get_node("HBox")
@onready var _a_Margin: Control = get_node("HBox/Margin")
@onready var _a_Desc: Label = get_node("HBox/Desc")

func _ready() -> void:
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func set_left_margin(p_margin: float) -> void:
	_a_Margin.custom_minimum_size.x = p_margin

func set_hbox_modulate(p_color: Color) -> void:
	_a_HBox.set_modulate(p_color)

func set_desc_modulate(p_color: Color) -> void:
	_a_Desc.set_modulate(p_color)

func set_desc(p_text: String) -> void:
	_a_Desc.set_text(p_text)

func _on_focus_entered() -> void:
	_a_Outlines.set_self_modulate(_a_FOCUS_COLOR)

func _on_focus_exited() -> void:
	_a_Outlines.set_self_modulate(_a_NORMAL_COLOR)
