extends FWExtensionBase
class_name FWCompPopupShared

signal finished()

var _a_Anims: AnimationPlayer
var _a_Audio: AudioStreamPlayer
var _a_Timer: Timer

var _a_by_command: bool = false # Popup used by popup command

func init(p_entities: Array[Node]) -> void:
	var entity_entity_comph: FWCompHandler = p_entities[-1].comph()
	if entity_entity_comph.has_comp("Interactions"):
		var interactions_comp: Node = entity_entity_comph.get_comp("Interactions")
		interactions_comp.interaction_activated.connect(_on_Interactions_interaction_activated)
		interactions_comp.interaction_deactivated.connect(_on_Interactions_interaction_deactivated)

func ready() -> void:
	_a_Anims = _a_entity.get_node("Anims")
	_a_Audio = _a_entity.get_node("Audio")
	_a_Timer = _a_entity.get_node("Timer")
	
	_a_Anims.animation_finished.connect(_on_anim_finished)
	_a_Timer.timeout.connect(_on_Timer_timeout)

func popup(p_type: StringName, p_by_command: bool) -> void:
	update_texture(p_type)
	play_anim(&"Fade_In")
	_a_by_command = p_by_command

func update_texture(p_type: StringName) -> void:
	var popup_path: String = Global.get_popup_path()
	_a_entity.set_texture(load(popup_path % p_type))

func reset() -> void:
	_a_Audio.stop()
	_a_Timer.stop()
	play_anim(&"Faded_Out")

func play_anim(p_name: StringName) -> void:
	_a_Anims.play(p_name)

func seek_anim(p_seconds: float, p_update: bool) -> void:
	_a_Anims.seek(p_seconds, p_update)

func start_timer(p_seconds: float) -> void:
	_a_Timer.start(p_seconds)

func get_anim_pos() -> float:
	return _a_Anims.get_current_animation_position()

func get_assigned_anim() -> StringName:
	return _a_Anims.get_assigned_animation()

func get_timer_time_left() -> float:
	return _a_Timer.get_time_left()

func _on_Interactions_interaction_activated(p_area: Node) -> void:
	var popup_pos: Variant = p_area.get_popup_pos()
	var popup_type: StringName = p_area.get_popup_type()
	_a_entity.set_position(popup_pos)
	popup(popup_type, false)

func _on_Interactions_interaction_deactivated() -> void:
	play_anim(&"Fade_Out")

func _on_anim_finished(p_name: StringName) -> void:
	if !_a_by_command:
		return
	
	match p_name:
		&"Fade_In":
			_a_Audio.play()
			start_timer(0.5)
		&"Fade_Out":
			finished.emit()

func _on_Timer_timeout() -> void:
	play_anim(&"Fade_Out")
