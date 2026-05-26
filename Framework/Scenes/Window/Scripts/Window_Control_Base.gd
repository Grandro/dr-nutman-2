extends VBoxContainer
class_name FWWindowControlBase

signal closed()
signal return_pressed() 

enum Corners {NONE, TOP_LEFT, TOP, TOP_RIGHT, RIGHT,
			  BOTTOM_RIGHT, BOTTOM, BOTTOM_LEFT, LEFT}

@export var _e_window_title: String = ""
@export var _e_resizable: bool = false
@export var _e_closeable: bool = true
@export var _e_show_return: bool = false

@onready var _a_Bar: PanelContainer = get_node("Bar")
@onready var _a_Return: TextureButton = get_node("Bar/HBox/Return")
@onready var _a_Heading: Label = get_node("Bar/HBox/Heading")
@onready var _a_Close: TextureButton = get_node("Bar/HBox/Close")

var _a_dragging: bool = false
var _a_can_resize: bool = false
var _a_resizing: bool = false
var _a_resize_corner: Corners = Corners.NONE

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	_a_Return.pressed.connect(_on_Return_pressed)
	_a_Bar.gui_input.connect(_on_Bar_gui_input)
	_a_Close.pressed.connect(_on_Close_pressed)
	
	set_title(tr(_e_window_title))
	set_resizable(_e_resizable)
	set_return_visible(_e_show_return)

func _resize_logic(p_event: InputEvent) -> void:
	if !_a_resizing:
		var mouse_pos: Vector2 = p_event.get_position()
		_update_resize(mouse_pos)
	
	if Input.is_action_pressed(&"Mouse_Left"):
		_a_resizing = _a_can_resize
	else:
		_a_resizing = false
	
	if _a_resizing:
		var vp_size: Vector2 = get_viewport_rect().size
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		mouse_pos = Vector2(max(mouse_pos.x, 0), max(mouse_pos.y, 0))
		mouse_pos = Vector2(min(mouse_pos.x, vp_size.x), min(mouse_pos.y, vp_size.y))
		var global_pos: Vector2 = get_global_position()
		var diff: Vector2 = mouse_pos - global_pos
		
		var min_size: Vector2 = get_combined_minimum_size()
		var size_: Vector2 = get_size()
		var pos: Vector2 = get_position()
		
		match _a_resize_corner:
			Corners.TOP_LEFT:
				var new_size: Vector2 = size_ - diff
				set_size(new_size)
				
				var new_pos: Vector2 = _get_new_position(pos + diff)
				if new_size.x <= min_size.x:
					size_.x = min_size.x
					new_pos.x = pos.x + (size_.x - min_size.x)
				if new_size.y <= min_size.y:
					size_.y = min_size.y
					new_pos.y = pos.y + (size_.y - min_size.y)
				set_position(new_pos)
			
			Corners.TOP:
				var new_size: Vector2 = Vector2(size_.x, size_.y - diff.y)
				set_size(new_size)
				
				var new_pos: Vector2 = _get_new_position(Vector2(pos.x, pos.y + diff.y))
				if new_size.y <= min_size.y:
					size_.y = min_size.y
					new_pos.y = pos.y + (size_.y - min_size.y)
				set_position(new_pos)
			
			Corners.TOP_RIGHT:
				var new_size: Vector2 = Vector2(diff.x, size_.y - diff.y)
				set_size(new_size)
				
				var new_pos: Vector2 = _get_new_position(Vector2(pos.x, pos.y + diff.y))
				if new_size.y <= min_size.y:
					size_.y = min_size.y
					new_pos.y = pos.y + (size_.y - min_size.y)
				set_position(new_pos)
			
			Corners.RIGHT:
				var new_size: Vector2 = Vector2(diff.x, size_.y)
				set_size(new_size)
				set_position(pos)
			
			Corners.BOTTOM_RIGHT:
				set_size(diff)
			
			Corners.BOTTOM:
				var new_size: Vector2 = Vector2(size_.x, diff.y)
				set_size(new_size)
				set_position(pos)
			
			Corners.BOTTOM_LEFT:
				var new_size: Vector2 = Vector2(size_.x - diff.x, diff.y)
				set_size(new_size)
				
				var new_pos: Vector2 = _get_new_position(Vector2(pos.x + diff.x, pos.y))
				if new_size.x <= min_size.x:
					size_.x = min_size.x
					new_pos.x = pos.x + (size_.x - min_size.x)
				set_position(new_pos)
			
			Corners.LEFT:
				var new_size: Vector2 = Vector2(size_.x - diff.x, size_.y)
				set_size(new_size)
				
				var new_pos: Vector2 = _get_new_position(Vector2(pos.x + diff.x, pos.y))
				if new_size.x <= min_size.x:
					size_.x = min_size.x
					new_pos.x = pos.x + (size_.x - min_size.x)
				set_position(new_pos)
	else:
		if !_a_can_resize:
			_a_resize_corner = Corners.NONE
			set_default_cursor_shape(Control.CURSOR_ARROW)

func _update_resize(p_pos: Vector2) -> void:
	var size_: Vector2 = get_size()
	var top: float = 0.0
	var left: float = 0.0
	var right: float = size_.x
	var bottom: float = size_.y
	
	_a_can_resize = true
	
	# Top_Left, Bottom_Left, Left
	if p_pos.x - left <= 4.0:
		if p_pos.y - top <= 4.0:
			set_default_cursor_shape(Control.CURSOR_FDIAGSIZE)
			_a_resize_corner = Corners.TOP_LEFT
		elif bottom - p_pos.y <= 4.0:
			set_default_cursor_shape(Control.CURSOR_BDIAGSIZE)
			_a_resize_corner = Corners.BOTTOM_LEFT
		else:
			set_default_cursor_shape(Control.CURSOR_HSIZE)
			_a_resize_corner = Corners.LEFT
		return
	
	# Top_Right, Bottom_Right, Right
	if right - p_pos.x <= 4.0:
		if p_pos.y - top <= 4.0:
			set_default_cursor_shape(Control.CURSOR_BDIAGSIZE)
			_a_resize_corner = Corners.TOP_RIGHT
		elif bottom - p_pos.y <= 4.0:
			set_default_cursor_shape(Control.CURSOR_FDIAGSIZE)
			_a_resize_corner = Corners.BOTTOM_RIGHT
		else:
			set_default_cursor_shape(Control.CURSOR_HSIZE)
			_a_resize_corner = Corners.RIGHT
		return
	
	# Top
	if p_pos.y - top <= 4.0:
		set_default_cursor_shape(Control.CURSOR_VSIZE)
		_a_resize_corner = Corners.TOP
		return
	
	# Bottom
	if bottom - p_pos.y <= 4.0:
		set_default_cursor_shape(Control.CURSOR_VSIZE)
		_a_resize_corner = Corners.BOTTOM
		return
	
	_a_can_resize = false

func set_title(p_title: String) -> void:
	_a_Heading.set_text(p_title)
	_e_window_title = p_title

func set_resizable(p_resizable: bool) -> void:
	if p_resizable:
		set_mouse_filter(Control.MOUSE_FILTER_PASS)
	else:
		set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	_e_resizable = p_resizable

func set_closeable(p_closeable: bool) -> void:
	_e_closeable = p_closeable

func set_return_visible(p_visible: bool) -> void:
	_a_Return.set_visible(p_visible)

func _get_new_position(p_pos: Vector2) -> Vector2:
	var pos: Vector2 = get_position()
	var size_: Vector2 = get_size()
	var top: float = pos.y
	var left: float = pos.x
	var right: float = left + size_.x
	var bottom: float = top + size_.y

	var vp_rect: Rect2 = get_viewport_rect()
	var vp_top: float = vp_rect.position.y
	var vp_left: float = vp_rect.position.x
	var vp_right: float = vp_left + vp_rect.size.x
	var vp_bottom: float = vp_top + vp_rect.size.y
	var new_pos: Vector2 = p_pos

	if p_pos.x < vp_left:
		new_pos.x = vp_left
	elif p_pos.x + (right - left) > vp_right:
		new_pos.x = vp_right - (right - left)

	if p_pos.y < vp_top:
		new_pos.y = vp_top
	elif p_pos.y + (bottom - top) > vp_bottom:
		new_pos.y = vp_bottom - (bottom - top)

	return new_pos

func _on_gui_input(p_event: InputEvent) -> void:
	if _a_dragging:
		return
	
	_resize_logic(p_event)

func _on_Return_pressed() -> void:
	return_pressed.emit()

func _on_Bar_gui_input(p_event: InputEvent) -> void:
	if !_a_dragging && _e_resizable:
		_resize_logic(p_event)
		if _a_resizing:
			get_viewport().set_input_as_handled()
			return
	
	if Input.is_action_pressed(&"Mouse_Left"):
		if p_event is InputEventMouseMotion:
			var relative: Vector2 = p_event.get_relative()
			var pos: Vector2 = get_position() + relative
			var new_pos: Vector2 = _get_new_position(pos)
			_set_position(new_pos)
		
		_a_dragging = true
	else:
		_a_dragging = false

func _on_Close_pressed() -> void:
	if _e_closeable:
		hide()
		closed.emit()
