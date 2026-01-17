extends Control
class_name SVPartyMemberCompShieldBarUIBase

signal anim_finished(p_name: StringName)
signal progress_updated()

@onready var _a_Progress: ProgressBar = get_node("Progress")
@onready var _a_Anims: AnimationPlayer = get_node("Anims")

func _ready() -> void:
	_a_Anims.animation_finished.connect(_on_anim_finished)

func play_anim(p_name: StringName) -> void:
	_a_Anims.play(p_name)

func update_progress(p_shield: int) -> void:
	var value: int = int(_a_Progress.get_value())
	var tween: Tween = create_tween()
	tween.finished.connect(_on_Tween_finished)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_a_Progress, "value", p_shield, 0.5).from(value)

func set_progress_value(p_value: int) -> void:
	_a_Progress.set_value(p_value)

func get_progress_max() -> int:
	return int(_a_Progress.get_max())

func _on_anim_finished(p_name: StringName) -> void:
	anim_finished.emit(p_name)

func _on_Tween_finished() -> void:
	progress_updated.emit()
