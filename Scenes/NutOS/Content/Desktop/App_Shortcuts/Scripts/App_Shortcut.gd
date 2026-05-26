extends MarginContainer
class_name NutOSContentDesktopAppShortcut

signal activated()
signal left_pressed()
signal left_released()
signal right_pressed()

@export var _e_app_path: String = ""

var _a_Style_Focus: StyleBoxFlat = preload("uid://bdjmty0dlicg1")
var _a_Style_Normal: StyleBoxEmpty = preload("uid://dfhyf4va8n5c2")

@onready var _a_Select: Button = get_node("Select")

var _a_key: StringName
var _a_drag_offset: Vector2 = Vector2.ZERO
var _a_cell: Vector2i

func _ready() -> void:
	_a_Select.gui_input.connect(_on_Select_gui_input)
	set_physics_process(false)

func _physics_process(_p_delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	set_global_position(mouse_pos - _a_drag_offset)

func fake_focus(p_fake_focus: bool) -> void:
	if p_fake_focus:
		_a_Select.set(&"theme_override_styles/normal", _a_Style_Focus)
	else:
		_a_Select.set(&"theme_override_styles/normal", _a_Style_Normal)

func get_app_path() -> String:
	return _e_app_path

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key

func set_drag_offset(p_drag_offset: Vector2) -> void:
	_a_drag_offset = p_drag_offset

func set_cell(p_cell: Vector2i) -> void:
	_a_cell = p_cell

func get_cell() -> Vector2i:
	return _a_cell

func _on_Select_gui_input(p_event: InputEvent) -> void:
	if p_event is InputEventMouseButton:
		var button_idx: MouseButton = p_event.get_button_index()
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
