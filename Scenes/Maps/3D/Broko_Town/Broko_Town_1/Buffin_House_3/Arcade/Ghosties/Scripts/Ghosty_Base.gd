extends FWCharacter3DObject
class_name ArcadeGhostyBase

signal state_changed(p_old_state: StringName, p_new_state: StringName)

@export var _e_target: Node3D
@export var _e_color: Color

var _a_Spritesheet: Texture2D = preload("uid://dvafsb44rr3jr")
var _a_Spritesheet_Blue: Texture2D = preload("uid://b6d6y45wt1oyc")
var _a_Spritesheet_White: Texture2D = preload("uid://bykbne6alpxa6")
var _a_Spritesheet_Eyes: Texture2D = preload("uid://dpeb6r0fd4atg")

@onready var _a_Display: FWCompDisplay3D = get_node("Display")
@onready var _a_Behavior: FWObjectCompBehaviorBase = get_node("Behavior")
@onready var _a_Dazzled_Blue: Timer = get_node("Dazzled_Blue")
@onready var _a_Dazzled_Blink: Timer = get_node("Dazzled_Blink")
@onready var _a_Dazzled_CD: Timer = get_node("Dazzled_CD")

var _a_state: StringName = &"Normal"
var _a_dazzled_blink_blue: bool = true
var _a_defeated: bool = false

func _ready() -> void:
	super()
	_a_Dazzled_Blue.timeout.connect(_on_Dazzled_Blue_timeout)
	_a_Dazzled_Blink.timeout.connect(_on_Dazzled_Blink_timeout)
	_a_Dazzled_CD.timeout.connect(_on_Dazzled_CD_timeout)
	
	_a_Behavior.set_target(_e_target)
	_a_Display.set_modulate(_e_color)

func set_state(p_state: StringName) -> void:
	var old_state: StringName = _a_state
	_a_state = p_state
	_a_dazzled_blink_blue = true
	_a_Dazzled_Blue.stop()
	_a_Dazzled_Blink.stop()
	_a_Dazzled_CD.stop()
	
	match p_state:
		&"Normal":
			_a_Display.set_hframes(8)
			_a_Display.set_vframes(2)
			_a_Display.set_texture(_a_Spritesheet)
			_a_Display.set_modulate(_e_color)
		&"Dazzled":
			_a_Display.set_hframes(2)
			_a_Display.set_vframes(1)
			_a_Display.set_texture(_a_Spritesheet_Blue)
			_a_Display.set_modulate(Color.WHITE)
			_a_Behavior.set_state(&"Dazzled")
			if !_a_defeated:
				_a_Dazzled_Blue.start()
		&"Return":
			_a_Display.set_hframes(2)
			_a_Display.set_vframes(1)
			_a_Display.set_texture(_a_Spritesheet_Eyes)
			_a_Display.set_modulate(Color.WHITE)
			_a_Behavior.set_state(&"Return")
	
	state_changed.emit(old_state, p_state)

func get_state() -> StringName:
	return _a_state

func set_defeated(p_defeated: bool) -> void:
	_a_defeated = p_defeated

func get_defeated() -> bool:
	return _a_defeated

func get_stay_area() -> Area3D:
	return null

func _on_Dazzled_Blue_timeout() -> void:
	_a_dazzled_blink_blue = false
	_a_Display.set_texture(_a_Spritesheet_White)
	_a_Dazzled_Blink.start()
	_a_Dazzled_CD.start()

func _on_Dazzled_Blink_timeout() -> void:
	_a_dazzled_blink_blue = !_a_dazzled_blink_blue
	if _a_dazzled_blink_blue:
		_a_Display.set_texture(_a_Spritesheet_Blue)
	else:
		_a_Display.set_texture(_a_Spritesheet_White)

func _on_Dazzled_CD_timeout() -> void:
	set_state(&"Normal")
	_a_Behavior.set_state(&"Move")
