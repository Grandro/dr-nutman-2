extends "res://Scenes/Maps/3D/Broko_Town/Broko_Town_1/Objects/Comps/Balloons/Scripts/Container_Base.gd"

var _a_entity = null

func _physics_process(p_delta):
	var entity_velocity = _a_entity.get_real_velocity()
	entity_velocity = entity_velocity.normalized()
	
	var impulse = -entity_velocity * p_delta * 0.2
	_a_Balloon.apply_central_impulse(impulse)

func set_entity(p_entity):
	_a_entity = p_entity
