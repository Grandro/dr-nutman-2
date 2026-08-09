extends CanvasLayer

signal opened()
signal closed()
signal input_proceeded(p_input: String)

@export var _e_hold_down: float = 0.16
@export var _e_max_input: int = 30

const _a_DIRS: Array[String] = ["down", "left", "right", "up"]

var _a_Keys_HBox_Scene: PackedScene = preload("uid://b2c0llgtbtt4x")
var _a_Key_Scene: PackedScene = preload("uid://ctrt4xul7i2hc")

@onready var _a_Control: Control = get_node("Control")
@onready var _a_Hold_Down: Timer = get_node("Control/Hold_Down")
@onready var _a_Back_Text: Label = get_node("Control/Explanation/Back/Text")
@onready var _a_Input_Text: Label = get_node("Control/VBox/HBox/Input")
@onready var _a_Keys_HBoxs: VBoxContainer = get_node("Control/VBox/Keys_HBoxs")
@onready var _a_SFX_Dir_Pressed: AudioStreamPlayer = get_node("SFX/Dir_Pressed")
@onready var _a_SFX_Button_Down: AudioStreamPlayer = get_node("SFX/Button_Down")
@onready var _a_SFX_Button_Up: AudioStreamPlayer = get_node("SFX/Button_Up")
@onready var _a_SFX_Back: AudioStreamPlayer = get_node("SFX/Back")
@onready var _a_SFX_Proceed: AudioStreamPlayer = get_node("SFX/Proceed")

var _a_held_dir: String = ""
var _a_input: String = ""
var _a_button_down: bool = false
var _a_focused_color: Color = Color.WHITE

func _ready() -> void:
	_a_Hold_Down.timeout.connect(_on_Hold_Down_timeout)
	Databases.data_loaded.connect(_on_Databases_data_loaded)
	Global_Data.keyboard_layout_changed.connect(_on_Global_Data_keyboard_layout_changed)
	Global_Data.fav_color_changed.connect(_on_Global_Data_fav_color_changed)
	
	_a_Hold_Down.set_wait_time(_e_hold_down)
	
	set_process(false)
	set_process_input(false)
	
	_a_Control.hide()

func _process(_p_delta: float) -> void:
	if !_a_held_dir.is_empty():
		var event_name: String = "ui_%s" % _a_held_dir
		if !Input.is_action_pressed(event_name):
			_a_held_dir = ""
			_a_Hold_Down.stop()

func _input(p_event: InputEvent) -> void:
	if !_a_button_down:
		for dir: String in _a_DIRS:
			var event_name: String = "ui_%s" % dir
			if p_event.is_action_pressed(event_name):
				_a_held_dir = dir
				_a_Hold_Down.start()
	
	if p_event.is_action_pressed(&"ui_cancel"):
		if _a_input.is_empty():
			_a_SFX_Back.set_pitch_scale(1.0)
			_a_SFX_Back.play()
			close()
		else:
			_a_SFX_Back.set_pitch_scale(1.25)
			_a_SFX_Back.play()
			_a_input = _a_input.left(_a_input.length() - 1)
			_a_Input_Text.set_text(_a_input)
			_update_back_text()
		get_viewport().set_input_as_handled()
	
	elif p_event.is_action_pressed(&"Joy_X"):
		_input_proceeded()
		get_viewport().set_input_as_handled()

func open(p_input: String = "") -> void:
	var hbox: HBoxContainer = _a_Keys_HBoxs.get_child(0)
	var instance: FWVirtualKeyboardKey = hbox.get_child(0)
	instance.grab_focus()
	_a_input = p_input
	_a_Input_Text.set_text(p_input)
	_update_back_text()
	_a_Control.show()
	
	opened.emit()
	
	# Fix for Joypad_Up/Left/Right/Up being pressed (Sound being played)
	#await get_tree().process_frame
	#await get_tree().process_frame
	
	set_process(true)
	set_process_input(true)

func close() -> void:
	input_proceeded.emit(_a_input)
	_reset()
	closed.emit()

func _input_proceeded() -> void:
	_a_SFX_Proceed.play()
	close()

func _reset() -> void:
	set_process(false)
	set_process_input(false)
	_set_keys_focus_mode(_a_Control.FOCUS_ALL)
	_a_input = ""
	_a_Input_Text.set_text("")
	_a_Hold_Down.stop()
	_a_Control.hide()

func _update_key_instances(p_keyboard_layout: StringName) -> void:
	for child: HBoxContainer in _a_Keys_HBoxs.get_children():
		_a_Keys_HBoxs.remove_child(child)
		child.queue_free()
	
	var data: FWKeyboardLayoutData = Databases.get_data_entry(&"Keyboard_Layouts", p_keyboard_layout)
	for entry: Array in data.get_layout():
		var keys_hbox: HBoxContainer = _a_Keys_HBox_Scene.instantiate()
		for idx: int in entry:
			var idx_str: String = str(idx)
			var instance: FWVirtualKeyboardKey = _a_Key_Scene.instantiate()
			instance.button_down.connect(_on_Key_button_down.bind(instance))
			instance.button_up.connect(_on_Key_button_up)
			instance.focus_entered.connect(_on_Key_focus_entered.bind(instance))
			instance.focus_exited.connect(_on_Key_focus_exited.bind(instance))
			instance.set_char_idx(idx)
			instance.set_name(idx_str)
			instance.set_key_texture.call_deferred(idx_str)
			
			keys_hbox.add_child(instance)
		_a_Keys_HBoxs.add_child(keys_hbox)
	
	_set_focus_neighbours()

func _update_back_text() -> void:
	if _a_input.is_empty():
		_a_Back_Text.set_text(tr(&"FW_CLOSE"))
	else:
		_a_Back_Text.set_text(tr(&"FW_BACK"))

func _set_focus_neighbours() -> void:
	var hboxs_count: int = _a_Keys_HBoxs.get_child_count()
	for i: int in hboxs_count:
		var hbox_instance: HBoxContainer = _a_Keys_HBoxs.get_child(i)
		var key_count: int = hbox_instance.get_child_count()
		for j: int in key_count:
			var key_instance: FWVirtualKeyboardKey = hbox_instance.get_child(j)
			var down: FWVirtualKeyboardKey
			var left: FWVirtualKeyboardKey
			var right: FWVirtualKeyboardKey
			var up: FWVirtualKeyboardKey
			
			# Left
			if j == 0:
				left = hbox_instance.get_child(key_count - 1)
			else:
				left = hbox_instance.get_child(j - 1)
			
			# Right
			if j == key_count - 1:
				right = hbox_instance.get_child(0)
			else:
				right = hbox_instance.get_child(j + 1)
			
			# Down
			var down_hbox: HBoxContainer
			if i == hboxs_count - 1:
				down_hbox = _a_Keys_HBoxs.get_child(0)
			else:
				down_hbox = _a_Keys_HBoxs.get_child(i + 1)
			
			var down_hbox_key_count: int = down_hbox.get_child_count()
			var diff: int = abs(key_count - down_hbox_key_count)
			var thresh: int = int(diff / 2.0)
			if down_hbox_key_count <= key_count:
				if j - thresh < 0:
					down = down_hbox.get_child(0)
				elif j - thresh >= down_hbox_key_count:
					down = down_hbox.get_child(down_hbox_key_count - 1)
				else:
					down = down_hbox.get_child(j - thresh)
			else:
				down = down_hbox.get_child(j + thresh)
			
			# Up
			var up_hbox: HBoxContainer
			if i == 0:
				up_hbox = _a_Keys_HBoxs.get_child(hboxs_count - 1)
			else:
				up_hbox = _a_Keys_HBoxs.get_child(i - 1)
			
			var up_hbox_key_count: int = up_hbox.get_child_count()
			diff = abs(key_count - up_hbox_key_count)
			thresh = int(diff / 2.0)
			
			if up_hbox_key_count <= key_count:
				if j - thresh < 0:
					up = up_hbox.get_child(0)
				elif j - thresh >= up_hbox_key_count:
					up = up_hbox.get_child(up_hbox_key_count - 1)
				else:
					up = up_hbox.get_child(j - thresh)
			else:
				up = up_hbox.get_child(j + thresh)
			
			key_instance.set_focus_neighbor(SIDE_LEFT, left.get_path())
			key_instance.set_focus_neighbor(SIDE_RIGHT, right.get_path())
			key_instance.set_focus_neighbor(SIDE_BOTTOM, down.get_path())
			key_instance.set_focus_neighbor(SIDE_TOP, up.get_path())

func _set_keys_focus_mode(p_focus_mode: Control.FocusMode, p_except: FWVirtualKeyboardKey = null) -> void:
	for hbox_instance: HBoxContainer in _a_Keys_HBoxs.get_children():
		for key_instance: FWVirtualKeyboardKey in hbox_instance.get_children():
			if key_instance != p_except:
				key_instance.set_focus_mode(p_focus_mode)

func _on_Hold_Down_timeout() -> void:
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	var next_path: NodePath
	match _a_held_dir:
		"down": next_path = focus_owner.get_focus_neighbor(SIDE_BOTTOM)
		"left": next_path = focus_owner.get_focus_neighbor(SIDE_LEFT)
		"right": next_path = focus_owner.get_focus_neighbor(SIDE_RIGHT)
		"up": next_path = focus_owner.get_focus_neighbor(SIDE_TOP)
	
	var next_instance: FWVirtualKeyboardKey = get_node(next_path)
	next_instance.grab_focus()

func _on_Databases_data_loaded() -> void:
	var keyboard_layout: StringName = Global_Data.get_options_controls_keyboard_layout()
	_a_focused_color = Global_Data.get_fav_color()
	
	_update_key_instances(keyboard_layout)

func _on_Global_Data_keyboard_layout_changed(p_keyboard_layout: StringName) -> void:
	_update_key_instances(p_keyboard_layout)

func _on_Global_Data_fav_color_changed(p_fav_color: Color) -> void:
	_a_focused_color = p_fav_color

func _on_Key_button_down(p_instance: FWVirtualKeyboardKey) -> void:
	_a_SFX_Button_Down.play()
	
	_a_button_down = true
	_set_keys_focus_mode(_a_Control.FOCUS_NONE, p_instance)
	if _a_input.length() == _e_max_input:
		return
	
	var char_idx: int = p_instance.get_char_idx()
	_a_input += char(char_idx)
	_a_Input_Text.set_text(_a_input)
	_update_back_text()

func _on_Key_button_up() -> void:
	if _a_button_down:
		_a_SFX_Button_Up.play()
	
	_a_button_down = false
	_set_keys_focus_mode(_a_Control.FOCUS_ALL)

func _on_Key_focus_entered(p_instance: FWVirtualKeyboardKey) -> void:
	p_instance.set_self_modulate(_a_focused_color)
	_a_SFX_Dir_Pressed.play()

func _on_Key_focus_exited(p_instance: FWVirtualKeyboardKey) -> void:
	p_instance.set_self_modulate(Color.WHITE)
