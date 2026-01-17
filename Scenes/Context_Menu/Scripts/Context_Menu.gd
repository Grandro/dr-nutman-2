extends CanvasLayer
class_name ContextMenu

signal option_selected(p_option: StringName)

@export var _e_margin_left: int = 8
@export var _e_margin_top: int = 8
@export var _e_margin_right: int = 8
@export var _e_margin_bottom: int = 8
@export var _e_option_entry_scene: PackedScene = null
@export var _e_options: Dictionary[StringName, ContextMenuOptionEntryData] = {} # Match key to entry data
@export var _e_options_order: Array[StringName] = []

var _a_HSep_Scene: PackedScene = preload("res://Scenes/Context_Menu/HSep.tscn")

const _a_OPTION_LEFT_LOC_ID: String = "CONTEXT_MENU_OPTIONS_%s_LEFT"
const _a_OPTION_RIGHT_LOC_ID: String = "CONTEXT_MENU_OPTIONS_%s_RIGHT"

@onready var _a_Content: PanelContainer = get_node("Content")
@onready var _a_Entries: VBoxContainer = get_node("Content/Entries")

var _a_options: Dictionary[StringName, ContextMenuOptionEntry] = {} # Match option key to Option_Entry instance

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	
	hide()

func _process(_p_delta: float) -> void:
	_a_Content.set_size(Vector2.ZERO)
	var pos: Vector2 = _a_Content.get_position()
	_update_content(pos)

func open(p_pos: Vector2) -> void:
	_create_options()
	set_process(true)
	set_process_input(true)
	
	_a_Content.set_position(p_pos)
	
	show()

func close() -> void:
	set_process(false)
	set_process_input(false)
	_a_options.clear()
	for child: Control in _a_Entries.get_children():
		_a_Entries.remove_child(child)
		child.queue_free()
	
	hide()

func _input(p_event: InputEvent) -> void:
	if p_event is InputEventMouseButton && p_event.is_pressed():
		var mouse_pos: Vector2 = p_event.get_position()
		if !has_rect_point(mouse_pos):
			close()

func _create_options() -> void:
	var hide_icon: bool = true
	for option: StringName in _e_options_order:
		var args: ContextMenuOptionEntryData = _e_options[option]
		if args.get_icon_texture() != null:
			hide_icon = false
			break
	
	for option: StringName in _e_options_order:
		var args: ContextMenuOptionEntryData = _e_options[option]
		var instance: Control
		var hsep: bool = args.get_hsep()
		if hsep:
			instance = _a_HSep_Scene.instantiate()
		else:
			instance = _e_option_entry_scene.instantiate()
			instance.select_pressed.connect(_on_Option_Entry_select_pressed.bind(option))
			instance.option_selected.connect(_on_Option_Entry_option_selected)
			
			var icon_texture: Texture2D = args.get_icon_texture()
			instance.set_icon_texture.call_deferred(icon_texture)
			if hide_icon:
				instance.hide_icon.call_deferred()
			
			var show_left: bool = args.get_show_left()
			if show_left:
				var left_text: String = tr(_a_OPTION_LEFT_LOC_ID % option.to_upper())
				instance.set_left_text.call_deferred(left_text)
			else:
				instance.hide_left.call_deferred()
			
			var show_right: bool = args.get_show_right()
			if show_right:
				var right_text: String = tr(_a_OPTION_RIGHT_LOC_ID % option.to_upper())
				instance.set_right_text.call_deferred(right_text)
			else:
				instance.hide_right.call_deferred()
			
			instance.set_sub_menu_layer(get_layer())
			instance.set_option_entry_scene(_e_option_entry_scene)
			instance.set_options(args.get_options())
			instance.set_options_order(args.get_options_order())
			instance.set_disabled.call_deferred(args.get_disabled())
			instance.set_visible(args.get_visible())
			
			_a_options[option] = instance
		
		instance.set_theme(_a_Content.get_theme())
		
		_a_Entries.add_child(instance)

func _update_content(p_pos: Vector2) -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	var size: Vector2 = _a_Content.get_size()
	p_pos.x = max(_e_margin_left, p_pos.x)
	p_pos.y = max(_e_margin_top, p_pos.y)
	p_pos.x = min(vp_size.x - size.x - _e_margin_right, p_pos.x)
	p_pos.y = min(vp_size.y - size.y - _e_margin_bottom, p_pos.y)
	
	_a_Content.set_position(p_pos)

func set_option_disabled(p_option: StringName, p_disabled: bool) -> void:
	var args: ContextMenuOptionEntryData = _e_options[p_option]
	args.set_disabled(p_disabled)
	
	if !_a_options.is_empty():
		var instance: ContextMenuOptionEntry = _a_options[p_option]
		instance.set_disabled(p_disabled)

func set_options_disabled_all(p_disabled: bool, p_exclude = []) -> void:
	set_options_disabled(_e_options_order, p_disabled, false, p_exclude)

func set_options_disabled(p_options: Array[StringName], p_disabled: bool, p_flip_others: bool, p_exclude = []) -> void:
	for option: StringName in _e_options_order:
		if p_exclude.has(option):
			continue
		
		if p_options.has(option):
			set_option_disabled(option, p_disabled)
		elif p_flip_others:
			set_option_disabled(option, !p_disabled)

func set_option_visible(p_option: StringName, p_visible: bool) -> void:
	var args: ContextMenuOptionEntryData = _e_options[p_option]
	args.set_visible(p_visible)
	
	if !_a_options.is_empty():
		var instance: ContextMenuOptionEntry = _a_options[p_option]
		instance.set_visible(p_visible)

func set_option_entry_scene(p_option_entry_scene: PackedScene) -> void:
	_e_option_entry_scene = p_option_entry_scene

func set_options(p_options: Dictionary[StringName, ContextMenuOptionEntryData]) -> void:
	_e_options = p_options

func set_options_order(p_options_order: Array[StringName]) -> void:
	_e_options_order = p_options_order

func set_theme(p_theme: Theme) -> void:
	_a_Content.set_theme(p_theme)

func has_rect_point(p_point: Vector2) -> bool:
	var rect: Rect2 = _a_Content.get_rect()
	var has_point: bool = rect.has_point(p_point)
	if has_point:
		return true
	
	for child: Control in _a_Entries.get_children():
		if child is HSeparator:
			continue
		
		if child.has_sub_menu_rect_point(p_point):
			has_point = true
			break
	
	return has_point

func _on_Option_Entry_select_pressed(p_option: StringName) -> void:
	option_selected.emit(p_option)
	close()

func _on_Option_Entry_option_selected(p_option: StringName) -> void:
	option_selected.emit(p_option)
	close()
