extends AnimationPlayer
class_name FWCompAnims

signal anim_seeked(p_seconds: float, p_update: bool)
signal anim_stopped(p_reset: bool)
signal anim_played(p_name: StringName)

@export var _e_use_dir_name: bool = false
@export var _e_seek_on_load: bool = true

var _a_entity_comph: FWCompHandler

func init(p_entities: Array[Node]) -> void:
	_a_entity_comph = p_entities[-1].comph()
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)

func update_anim() -> void:
	if !_a_entity_comph.has_comp("States"):
		return
	
	var anim_name: StringName = _a_entity_comph.call_comp("States", &"get_state_tmp")
	if _e_use_dir_name:
		var dir_name: StringName = _get_dir_name()
		if dir_name != &"":
			anim_name = "%s_%s" % [anim_name, dir_name]
	
	play_anim(anim_name)

func play_anim(p_name: StringName, p_speed: float = 1.0, p_backwards: bool = false) -> void:
	if p_backwards:
		play(p_name, -1, -p_speed, true)
	else:
		play(p_name, -1, p_speed)
	anim_played.emit(p_name)

func seek_anim(p_seconds: float, p_update: bool = false) -> void:
	seek(p_seconds, p_update)
	anim_seeked.emit(p_seconds, p_update)

func stop_anim(p_keep_state: bool = false) -> void:
	stop(p_keep_state)
	anim_stopped.emit(p_keep_state)

func _get_dir_name() -> StringName:
	var dir_name: StringName = &""
	if _a_entity_comph.has_comp("Movement"):
		var dir_vec: Variant = _a_entity_comph.call_comp("Movement", &"get_dir_vec")
		if _a_entity_comph.has_comp("Display"):
			var display_comp: Node = _a_entity_comph.get_comp("Display")
			var billboard: bool = display_comp.get_billboard()
			if billboard:
				var rotation_degrees: Variant = display_comp.get_global_rotation_degrees()
				dir_vec = Global.get_dir_vec_rotated(dir_vec, rotation_degrees.y)
		dir_name = Global.get_dir_vec_name(dir_vec)
	
	return dir_name

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	var curr: StringName = &""
	var pos: float = 0.0
	if is_playing():
		curr = get_current_animation()
		pos = get_current_animation_position()
	data[&"Curr"] = curr
	data[&"Pos"] = pos
	
	return data

func load_data(p_data: Dictionary) -> void:
	var curr: StringName = p_data[&"Curr"]
	if curr != &"":
		play_anim(curr)
		if _e_seek_on_load:
			var pos: float = p_data[&"Pos"]
			seek_anim(pos, true)

func load_data_init() -> void:
	pass

func _on_Comp_Handler_comps_registered() -> void:
	update_anim()
