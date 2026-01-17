extends CanvasLayer
class_name ObjectProjectorRotateMenu

@export var _e_rotate_speed: float = 100.0

@onready var _a_Turn_On_Off_Text: Label = get_node("Margin/Options/Turn_On_Off/Text")
@onready var _a_Back: IndicatorButton = get_node("Margin/Options/Back")

var _a_prev_camera: CompCamera3D # Previous camera
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
		var light_visible: bool = _a_model.get_light_visible()
		_a_projector.set_power(!light_visible)

func open() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	_a_prev_camera = global_si.get_curr_camera()
	
	var curr_camera: CompCamera3D = _a_model.get_camera()
	var player: Player3D = global_si.get_player()
	global_si.set_curr_camera(curr_camera)
	player.comph().call_comp("Operate", &"disable")
	
	set_process(true)
	set_process_unhandled_input(true)
	show()

func _close() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: Player3D = global_si.get_player()
	global_si.set_curr_camera(_a_prev_camera)
	player.comph().call_comp("Operate", &"enable")
	
	set_process(false)
	set_process_unhandled_input(false)
	hide()

func set_projector(p_projector: ObjectProjectorBase) -> void:
	_a_projector = p_projector
	p_projector.power_changed.connect(_on_Projector_power_changed)

func set_model(p_model: ObjectProjectorModel) -> void:
	_a_model = p_model

func _on_Back_select_pressed() -> void:
	_close()

func _on_Projector_power_changed(p_power: bool) -> void:
	if p_power:
		_a_Turn_On_Off_Text.set_text(tr(&"TURN_OFF"))
	else:
		_a_Turn_On_Off_Text.set_text(tr(&"TURN_ON"))
