extends MiniGameBaseIntro
class_name MiniGameColorSelectionIntro

@export var _e_camera_start_pos: Vector2 = Vector2(640, 464)
@export var _e_camera_end_pos: Vector2 = Vector2(640, 1224)

@onready var _a_Preview_Camera: CompCamera2D = get_node("Margin/VBox/HBox/Left/HBox/VP/VP/Game_Preview/Node2D/Camera")
@onready var _a_Preview_Scroll: VScrollBar = get_node("Margin/VBox/HBox/Left/HBox/Scroll")

func _ready() -> void:
	super()
	_a_Preview_Scroll.value_changed.connect(_on_Preview_Scroll_value_changed)

func _process(_p_delta: float) -> void:
	var camera_pos: Vector2 = _a_Preview_Camera.get_position()
	var pos_y: float = camera_pos.y - _e_camera_start_pos.y
	var end_y: float = _e_camera_end_pos.y - _e_camera_start_pos.y
	var value: float = pos_y / end_y * 100.0
	_a_Preview_Scroll.set_value(value)

func open() -> void:
	_a_Preview_Camera.set_position(_e_camera_start_pos)
	_a_Preview_Camera.set_zoom(Vector2(0.9, 0.9))
	_a_Preview_Camera.make_current_()
	super()

func _on_Preview_Scroll_value_changed(p_value: float) -> void:
	var pos_y: float = lerp(_e_camera_start_pos.y, _e_camera_end_pos.y, p_value / 100.0)
	_a_Preview_Camera.position.y = pos_y

func _on_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Fade_In": _a_game_preview.disable_flippers(false)
		&"Fade_Out": _a_game_preview.disable_flippers(true)
	super(p_name)
