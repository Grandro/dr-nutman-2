extends PanelContainer
class_name ContextMenuOptionEntry

signal select_pressed()
signal option_selected(p_option: StringName)

const _a_DISABLED_COLOR: Color = Color(0.5, 0.5, 0.5, 1.0)
const _a_NORMAL_COLOR: Color = Color.WHITE

var _a_Context_Menu_Scene: PackedScene = load("res://Scenes/Context_Menu/Context_Menu.tscn")

@onready var _a_Margin: MarginContainer = get_node("Margin")
@onready var _a_Icon: MarginContainer = get_node("Margin/HBox/Icon")
@onready var _a_Icon_Image: TextureRect = get_node("Margin/HBox/Icon/Image")
@onready var _a_Left: Label = get_node("Margin/HBox/Left")
@onready var _a_Right: Label = get_node("Margin/HBox/Right")
@onready var _a_Arrow: TextureRect = get_node("Margin/HBox/Arrow")
@onready var _a_Select: Button = get_node("Select")
@onready var _a_Expand_Timer: Timer = get_node("Expand_Timer")

var _a_sub_menu: ContextMenu = null # Instance of sub Context_Menu
var _a_sub_menu_layer: int # Layer for _a_sub_menu
var _a_option_entry_scene: PackedScene # Scene of Option_Entry for _a_sub_menu
var _a_options: Dictionary[StringName, ContextMenuOptionEntryData] # Options of _a_sub_menu
var _a_options_order: Array[StringName]
var _a_disabled: bool = false

func _ready() -> void:
	_a_Expand_Timer.timeout.connect(_on_Expand_Timer_timeout)
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Select.mouse_entered.connect(_on_Select_mouse_entered)
	_a_Select.mouse_exited.connect(_on_Select_mouse_exited)
	
	var has_sub_menu: bool = !_a_options.is_empty()
	_a_Arrow.set_visible(has_sub_menu)
	_a_Select.set_disabled(has_sub_menu)
	
	if has_sub_menu:
		_a_sub_menu = _a_Context_Menu_Scene.instantiate()
		_a_sub_menu.option_selected.connect(_on_Sub_Menu_option_selected)
		_a_sub_menu.set_layer(_a_sub_menu_layer)
		_a_sub_menu.set_option_entry_scene(_a_option_entry_scene)
		_a_sub_menu.set_options(_a_options)
		_a_sub_menu.set_options_order(_a_options_order)
		_a_sub_menu.set_theme.call_deferred(get_theme())
		_a_sub_menu.set_process_input.call_deferred(false)
		_a_sub_menu.hide()
		
		add_child(_a_sub_menu)

func _open_sub_menu() -> void:
	var width: float = get_size().x
	var pos: Vector2 = get_global_position()
	pos.x += width
	
	_a_sub_menu.open(pos)

func hide_icon() -> void:
	_a_Icon.hide()

func hide_left() -> void:
	_a_Left.hide()

func hide_right() -> void:
	_a_Right.hide()

func set_icon_texture(p_texture: Texture2D) -> void:
	_a_Icon_Image.set_texture(p_texture)

func set_left_text(p_text: String) -> void:
	_a_Left.set_text(p_text)

func set_right_text(p_text: String) -> void:
	_a_Right.set_text(p_text)

func set_sub_menu_layer(p_sub_menu_layer: int) -> void:
	_a_sub_menu_layer = p_sub_menu_layer

func set_option_entry_scene(p_option_entry_scene: PackedScene) -> void:
	_a_option_entry_scene = p_option_entry_scene

func set_options(p_options: Dictionary[StringName, ContextMenuOptionEntryData]) -> void:
	_a_options = p_options

func set_options_order(p_options_order: Array[StringName]) -> void:
	_a_options_order = p_options_order

func set_disabled(p_disabled: bool) -> void:
	if p_disabled:
		_a_Margin.set_modulate(_a_DISABLED_COLOR)
	else:
		_a_Margin.set_modulate(_a_NORMAL_COLOR)
	_a_Select.set_disabled(p_disabled)
	
	_a_disabled = p_disabled

func is_disabled() -> bool:
	return _a_disabled

func has_sub_menu_rect_point(p_point: Vector2) -> bool:
	var has_point: bool = false
	if is_instance_valid(_a_sub_menu):
		has_point = _a_sub_menu.has_rect_point(p_point)
	
	return has_point

func _on_Expand_Timer_timeout() -> void:
	_open_sub_menu()

func _on_Select_pressed() -> void:
	if _a_disabled:
		return
	
	if is_instance_valid(_a_sub_menu):
		_open_sub_menu()
	else:
		set_self_modulate(Color.TRANSPARENT)
		select_pressed.emit()

func _on_Select_mouse_entered() -> void:
	if _a_disabled:
		return
	
	set_self_modulate(_a_NORMAL_COLOR)
	if !is_instance_valid(_a_sub_menu):
		return
	
	if !_a_sub_menu.is_visible():
		_a_Expand_Timer.start(0.4)

func _on_Select_mouse_exited() -> void:
	if _a_disabled:
		return
	
	set_self_modulate(Color.TRANSPARENT)
	if !is_instance_valid(_a_sub_menu):
		return
	
	_a_Expand_Timer.stop()
	
	if _a_sub_menu.is_visible():
		var mouse_pos: Vector2 = get_local_mouse_position()
		var rect: Rect2 = get_rect()
		if !rect.has_point(mouse_pos):
			mouse_pos = get_viewport().get_mouse_position()
			if !_a_sub_menu.has_rect_point(mouse_pos):
				_a_sub_menu.close()

func _on_Sub_Menu_option_selected(p_option: StringName) -> void:
	option_selected.emit(p_option)
