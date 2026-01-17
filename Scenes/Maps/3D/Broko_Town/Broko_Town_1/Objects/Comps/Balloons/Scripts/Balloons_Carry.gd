extends CompBalloonsBase
class_name CompBalloonsCarry

@export var _e_containers_offset: Dictionary[StringName, Vector3] = {&"Down": Vector3.ZERO,
																	 &"Left": Vector3.ZERO,
																	 &"Right": Vector3.ZERO,
																	 &"Up": Vector3.ZERO}

@onready var _a_Anims: AnimationPlayer = get_node("Anims")

var _a_entity_comph: CompHandler

func init(p_entity) -> void:
	super(p_entity)
	_a_entity_comph = p_entity.comph()
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)
	
	for child: CompBalloonsContainerCarry in _a_Containers.get_children():
		child.set_entity(_a_entity)
		var key: StringName = child.get_name()
		_a_containers[key] = child
	
	if _a_containers.is_empty():
		set_process(false)

func instantiate_container(p_key: StringName, p_modulate: Color) -> CompBalloonsContainerCarry:
	var instance: CompBalloonsContainerCarry = super(p_key, p_modulate)
	instance.set_entity(_a_entity)

	return instance

func _update_containers_pos() -> void:
	var dir: StringName = _a_entity_comph.call_comp("Movement", &"get_dir")
	_a_Containers.position = _e_containers_offset[dir]

func load_data(p_data: Dictionary) -> void:
	_update_containers_pos()
	super(p_data)

func _on_Comp_Handler_comps_registered() -> void:
	var anims_comp: CompAnims = _a_entity_comph.get_comp("Anims")
	anims_comp.anim_seeked.connect(_on_Anims_anim_seeked)
	anims_comp.anim_stopped.connect(_on_Anims_anim_stopped)
	anims_comp.anim_played.connect(_on_Anims_anim_played)

func _on_Anims_anim_seeked(p_seconds: float, p_update: bool) -> void:
	_a_Anims.seek(p_seconds, p_update)

func _on_Anims_anim_stopped(p_reset: bool) -> void:
	_a_Anims.stop(p_reset)

func _on_Anims_anim_played(p_name: StringName) -> void:
	_update_containers_pos()
	
	var anim_comp: CompAnims = _a_entity_comph.get_comp("Anims")
	var speed: float = anim_comp.get_playing_speed()
	var pos: float = anim_comp.get_current_animation_position()
	var backwards: bool = speed < 0.0
	_a_Anims.play(p_name, -1, speed, backwards)
	if backwards:
		var length: float = anim_comp.get_current_animation_length()
		if pos < length:
			_a_Anims.seek(pos, false)
	else:
		if pos > 0.0:
			_a_Anims.seek(pos, false)
