extends SVEnemyGhostyCompActionsCommandAttackATK
class_name SVEnemyGhostyCompActionsCommandFloatInvisible

@export var _e_visible_min: float = 0.0
@export var _e_visible_max: float = 0.8
@export var _e_invisible_min: float = 0.1
@export var _e_invisible_max: float = 1.0

@onready var _a_Timer: Timer = get_node("Timer")

func process() -> void:
	super()
	var visible_time: float = randf_range(_e_visible_min, _e_visible_max)
	_a_Timer.timeout.connect(_on_Timer_timeout.bind(&"Visible"), CONNECT_ONE_SHOT)
	_a_Timer.start(visible_time)

func _on_Timer_timeout(p_state: StringName) -> void:
	match p_state:
		&"Visible":
			var tween: Tween = _tween_display_modulate(Color.WHITE, Color.TRANSPARENT)
			tween.finished.connect(_on_Tween_finished)
		&"Invisible":
			_tween_display_modulate(Color.TRANSPARENT, Color.WHITE)

func _on_Tween_finished() -> void:
	var invisible_time: float = randf_range(_e_invisible_min, _e_invisible_max)
	_a_Timer.timeout.connect(_on_Timer_timeout.bind(&"Invisible"), CONNECT_ONE_SHOT)
	_a_Timer.start(invisible_time)
