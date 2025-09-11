extends Node

var _a_entity : Node = null
var _a_entity_comph : CompHandler = null

var _a_global_si = null

var _a_walk_in = {} # Match area to body
var _a_press_key = {} # Match area to body
var _a_body = null # Curr best interaction body
var _a_area = null # Curr best interaction area

func _ready():
	_a_global_si = Global.get_singleton(self, "Global")

func _process(_delta):
	_handle_interactions()

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()

func _handle_interactions():
	_handle_interactions_walk_in()
	_handle_interactions_press_key()

func _handle_interactions_walk_in():
	for area in _a_walk_in:
		var body = _a_walk_in[area]
		if _can_interact_with(area, body):
			body.comph().call_comp("Interactions", "interaction", [area])

func _handle_interactions_press_key():
	var entity_pos = _a_entity_comph.call_comp("Interactions", "get_default_interaction_pos")
	var best_body = null
	var best_area = null
	var best_distance = -1.0
	for area in _a_press_key:
		var body = _a_press_key[area]
		if !_can_interact_with(area, body):
			continue
		
		var area_pos = area.get_global_position()
		var dir = Global.get_dir_to_pos(area_pos, entity_pos)
		body.comph().call_comp("Interactions", "interaction_update", [dir])
		
		var distance = entity_pos.distance_to(area_pos)
		if best_area == null:
			best_body = body
			best_area = area
			best_distance = distance
		elif distance < best_distance:
			best_body = body
			best_area = area
			best_distance = distance
	
	if _a_area != best_area:
		_set_interaction(best_body, best_area)

func _can_interact_with(p_area, p_body):
	var allowed = p_body.comph().call_comp("Interactions", "get_allowed")
	if !allowed:
		return false
	
	if p_body.comph().has_comp("Cutscene"):
		var in_cutscene = p_body.comph().call_comp("Cutscene", "is_in_cutscene")
		var disabled_by_cutscene = p_body.comph().call_comp("Cutscene", "is_disabled_by_cutscene")
		if in_cutscene || disabled_by_cutscene:
			return false
	
	var dirs = p_area.get_dirs().duplicate()
	var entity_dir = _a_entity_comph.call_comp("Movement", "get_dir")
	
	var needs_look_at = p_body.comph().call_comp("Interactions", "get_needs_look_at")
	if needs_look_at:
		var entity_pos = _a_entity_comph.call_comp("Interactions", "get_default_interaction_pos")
		var area_pos = p_area.get_global_position()
		var face_dir = Global.get_dir_to_pos(entity_pos, area_pos)
		if entity_dir != face_dir:
			return false
	
	var use_dir = p_area.get_use_dir()
	if use_dir:
		var body_dir = p_body.comph().call_comp("Movement", "get_dir")
		var body_rotation_deg = Global.get_dir_rotation_deg(body_dir).y
		for i in dirs.size():
			var dir = dirs[i]
			var rotated_dir = Global.get_dir_rotated(dir, -body_rotation_deg)
			dirs[i] = rotated_dir
	
	var use_transform = p_area.get_use_transform()
	if use_transform:
		var body_rotation_deg = p_body.get_global_rotation_degrees().y
		for i in dirs.size():
			var dir = dirs[i]
			var rotated_dir = Global.get_dir_rotated(dir, -body_rotation_deg)
			dirs[i] = rotated_dir
	
	if !dirs.has(entity_dir):
		return false
	
	return true

func _set_interaction(p_body, p_area):
	if is_instance_valid(_a_body):
		_a_body.comph().call_comp("Interactions", "interaction_deactivate", [_a_area])
	if is_instance_valid(p_body):
		var entity_dir = _a_entity_comph.call_comp("Movement", "get_dir")
		p_body.comph().call_comp("Interactions", "interaction_activate", [p_area, entity_dir])
	
	_a_body = p_body
	_a_area = p_area

func get_body():
	return _a_body

func get_area():
	return _a_area

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass

func _on_Interaction_area_entered(p_area):
	var interactions_comp = p_area.get_parent()
	var body = interactions_comp.get_entity()
	var type = p_area.get_type()
	match type:
		"Walk_In": _a_walk_in[p_area] = body
		"Press_Key": _a_press_key[p_area] = body

func _on_Interaction_area_exited(p_area):
	var type = p_area.get_type()
	match type:
		"Walk_In": _a_walk_in.erase(p_area)
		"Press_Key": _a_press_key.erase(p_area)
