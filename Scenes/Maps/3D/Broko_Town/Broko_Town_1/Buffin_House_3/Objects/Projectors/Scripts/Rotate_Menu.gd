extends CanvasLayer
class_name ObjectProjectorRotateMenu

@export var _e_rotate_speed: float = 100.0

@onready var _a_Turn_On_Off: VBoxContainer = get_node("Margin/Options/Turn_On_Off")
@onready var _a_Turn_On_Off_Text: Label = get_node("Margin/Options/Turn_On_Off/Text")
@onready var _a_Back: FWIndicatorButton = get_node("Margin/Options/Back")

var _a_open: bool = false
var _a_prev_camera: FWCompCamera3D
var _a_projector: ObjectProjectorBase
var _a_model: ObjectProjectorModel

func _ready() -> void:
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	set_process(false)
	set_process_unhandled_input(false)
	hide()

func _process(p_delta: float) -> void:
	if Input.is_action_pressed(&"Move_Left"):
		_a_projector.rotation_degrees.y += _e_rotate_speed * p_delta
	if Input.is_action_pressed(&"Move_Right"):
		_a_projector.rotation_degrees.y -= _e_rotate_speed * p_delta

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"OK"):
		var power: bool = _a_projector.get_power()
		_a_projector.set_power(!power)

func open() -> void:
	_a_open = true
	
	var global_si: Global = Global.get_singleton(self, "Global")
	_a_prev_camera = global_si.get_curr_camera()
	
	var curr_camera: FWCompCamera3D = _a_model.get_camera()
	var player: FWPlayer3D = global_si.get_object(&"Player")
	global_si.set_curr_camera(curr_camera)
	player.comph().call_comp("Operate", &"disable")
	
	set_process(true)
	set_process_unhandled_input(true)
	show()

func close() -> void:
	_a_open = false
	
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: FWPlayer3D = global_si.get_object(&"Player")
	global_si.set_curr_camera(_a_prev_camera)
	player.comph().call_comp("Operate", &"enable")
	
	set_process(false)
	set_process_unhandled_input(false)
	hide()

func set_turn_on_off_visible(p_turn_on_off_visible: bool) -> void:
	_a_Turn_On_Off.set_visible(p_turn_on_off_visible)

func is_open() -> bool:
	return _a_open

func set_projector(p_projector: ObjectProjectorBase) -> void:
	_a_projector = p_projector
	p_projector.power_changed.connect(_on_Projector_power_changed)

func set_model(p_model: ObjectProjectorModel) -> void:
	_a_model = p_model

func _on_Back_select_pressed() -> void:
	close()

func _on_Projector_power_changed(p_power: bool) -> void:
	if p_power:
		_a_Turn_On_Off_Text.set_text(tr(&"TURN_OFF"))
	else:
		_a_Turn_On_Off_Text.set_text(tr(&"TURN_ON"))
