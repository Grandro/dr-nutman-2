extends "res://Scenes/Maps/3D/Broko_Town/Broko_Town_1/Objects/Comps/Balloons/Scripts/Balloons_Base.gd"

@export var _e_containers_offset : Dictionary = {"Down": Vector3.ZERO,
												 "Left": Vector3.ZERO,
												 "Right": Vector3.ZERO,
												 "Up": Vector3.ZERO}

@onready var _a_Anims = get_node("Anims")

var _a_entity_comph = null

func init(p_entity):
	super(p_entity)
	_a_entity_comph = p_entity.comph()
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)
	
	for child in _a_Containers.get_children():
		child.set_entity(_a_entity)
		var key = child.get_name()
		_a_containers[key] = child
	
	if _a_containers.is_empty():
		set_process(false)

func instantiate_container(p_key, p_modulate):
	var instance = super(p_key, p_modulate)
	instance.set_entity(_a_entity)

func _update_containers_pos():
	var dir = _a_entity_comph.call_comp("Movement", "get_dir")
	_a_Containers.position = _e_containers_offset[dir]

func load_data(p_data):
	_update_containers_pos()
	super(p_data)

func _on_Comp_Handler_comps_registered():
	var anims_comp = _a_entity_comph.get_comp("Anims")
	anims_comp.anim_seeked.connect(_on_Anims_anim_seeked)
	anims_comp.anim_stopped.connect(_on_Anims_anim_stopped)
	anims_comp.anim_played.connect(_on_Anims_anim_played)

func _on_Anims_anim_seeked(p_seconds, p_update):
	_a_Anims.seek(p_seconds, p_update)

func _on_Anims_anim_stopped(p_reset):
	_a_Anims.stop(p_reset)

func _on_Anims_anim_played(p_name):
	_update_containers_pos()
	
	var anim_comp = _a_entity_comph.get_comp("Anims")
	var speed = anim_comp.get_playing_speed()
	var pos = anim_comp.get_current_animation_position()
	var backwards = speed < 0.0
	_a_Anims.play(p_name, -1, speed, backwards)
	if backwards:
		var length = anim_comp.get_current_animation_length()
		if pos < length:
			_a_Anims.seek(pos, false)
	else:
		if pos > 0.0:
			_a_Anims.seek(pos, false)
