extends MarginContainer

signal activated()
signal left_pressed()
signal left_released()
signal right_pressed()

@export var _e_app_path: String = ""

var _a_Style_Focus = preload("res://Scenes/NutOS/Content/Desktop/App_Shortcuts/Styles/Focus.tres")
var _a_Style_Normal = preload("res://Scenes/NutOS/Content/Desktop/App_Shortcuts/Styles/Normal.tres")

@onready var _a_Select = get_node("Select")

var _a_key = ""
var _a_drag_offset = Vector2.ZERO
var _a_cell = Vector2i(-1, -1)

func _ready():
	_a_Select.gui_input.connect(_on_Select_gui_input)
	set_physics_process(false)

func _physics_process(_p_delta):
	var mouse_pos = get_global_mouse_position()
	set_global_position(mouse_pos - _a_drag_offset)

func fake_focus(p_fake_focus):
	if p_fake_focus:
		_a_Select.set("theme_override_styles/normal", _a_Style_Focus)
	else:
		_a_Select.set("theme_override_styles/normal", _a_Style_Normal)

func get_app_path():
	return _e_app_path

func set_key(p_key):
	_a_key = p_key

func get_key():
	return _a_key

func set_drag_offset(p_drag_offset):
	_a_drag_offset = p_drag_offset

func set_cell(p_cell):
	_a_cell = p_cell

func get_cell():
	return _a_cell

func _on_Select_gui_input(p_event):
	if p_event is InputEventMouseButton:
		var button_idx = p_event.get_button_index()
		match button_idx:
			MOUSE_BUTTON_LEFT:
				if p_event.is_double_click():
					activated.emit()
				elif p_event.is_pressed():
					left_pressed.emit()
				else:
					left_released.emit()
			
			MOUSE_BUTTON_RIGHT:
				if p_event.is_pressed():
					right_pressed.emit()
