extends FWMiniGameGameBase
class_name MiniGameColorSelectionGameBase

@export var _e_camera_start_pos: Vector2 = Vector2(640, 464)
@export var _e_camera_end_pos: Vector2 = Vector2(640, 1224)

@onready var _a_Next_Color: MiniGameColorSelectionNextColor = get_node("Canvas_2/Next_Color")
@onready var _a_Camera: FWCompCamera2D = get_node("Node2D/Camera")
@onready var _a_Flippers: Node2D = get_node("Node2D/Flippers")

func _ready() -> void:
	super()
	set_process(false)
	disable_flippers(true)

func open() -> void:
	set_process(true)
	disable_flippers(false)
	super()

func _process(p_delta: float) -> void:
	var dir: Vector2 = Vector2.ZERO
	if Input.is_action_pressed(&"ui_up"):
		dir.y -= 1
	if Input.is_action_pressed(&"ui_down"):
		dir.y += 1
	
	var velocity: Vector2 = dir * p_delta * 700.0
	var pos: Vector2 = _a_Camera.get_position() + velocity
	pos = clamp(pos, _e_camera_start_pos, _e_camera_end_pos)
	_a_Camera.set_position(pos)

func disable_flippers(p_disabled: bool) -> void:
	for child: MiniGameColorSelectionFlipper1Base in _a_Flippers.get_children():
		child.set_process(!p_disabled)
		child.set_process_input(!p_disabled)
