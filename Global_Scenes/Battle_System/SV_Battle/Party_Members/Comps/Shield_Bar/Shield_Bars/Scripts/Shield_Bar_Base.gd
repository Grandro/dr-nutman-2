extends FWGUI3DPanel
class_name SVPartyMemberCompShieldBarBase

signal anim_finished(p_name: StringName)
signal progress_updated()

var _a_instance: SVPartyMemberCompShieldBarUIBase # Shield_Bar_UI instance

func _ready() -> void:
	_a_instance = _a_VP.get_child(0)
	_a_instance.anim_finished.connect(_on_Shield_Bar_UI_anim_finished)
	_a_instance.progress_updated.connect(_on_Shield_Bar_UI_progress_updated)

func process_effect(_p_entity: SVPartyMember) -> void:
	pass

func play_anim(p_name: StringName) -> void:
	_a_instance.play_anim(p_name)

func update_progress(p_shield: int) -> void:
	_a_instance.update_progress(p_shield)

func set_progress_value(p_value: int) -> void:
	_a_instance.set_progress_value(p_value)

func get_progress_max() -> int:
	return _a_instance.get_progress_max()

func _on_Shield_Bar_UI_anim_finished(p_name: StringName) -> void:
	anim_finished.emit(p_name)

func _on_Shield_Bar_UI_progress_updated() -> void:
	progress_updated.emit()
