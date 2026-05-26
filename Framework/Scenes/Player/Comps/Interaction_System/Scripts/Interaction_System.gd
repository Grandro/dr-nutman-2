extends Node
class_name FWPlayerCompInteractionSystem

var _a_entity: Node
var _a_entity_comph: FWCompHandler
var _a_global_si: Global

var _a_walk_in: Dictionary[Node, Node] = {} # Match area to body
var _a_press_key: Dictionary[Node, Node] = {} # Match area to body
var _a_body: Node = null # Curr best interaction body
var _a_area: Node = null # Curr best interaction area

func _ready() -> void:
	_a_global_si = Global.get_singleton(self, "Global")

func _process(_p_delta: float) -> void:
	_handle_interactions()

func init(p_entities: Array[Node]) -> void:
	_a_entity = p_entities[-1]
	_a_entity_comph = _a_entity.comph()

func _handle_interactions() -> void:
	_handle_interactions_walk_in()
	_handle_interactions_press_key()

func _handle_interactions_walk_in() -> void:
	for area: Node in _a_walk_in:
		var body: Node = _a_walk_in[area]
		if _can_interact_with(area, body):
			body.comph().call_comp("Interactions", &"interaction", [area])

func _handle_interactions_press_key() -> void:
	var entity_pos: Variant = _a_entity_comph.call_comp("Interactions", &"get_default_interaction_pos")
	var best_body = null
	var best_area = null
	var best_distance: float = -1.0
	for area: Node in _a_press_key:
		var body: Node = _a_press_key[area]
		if !_can_interact_with(area, body):
			continue
		
		var area_pos: Variant = area.get_global_position()
		var dir: StringName = Global.get_dir_to_pos(area_pos, entity_pos)
		body.comph().call_comp("Interactions", &"interaction_update", [dir])
		
		var distance: float = entity_pos.distance_to(area_pos)
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

func _can_interact_with(p_area: Node, p_body: Node) -> bool:
	var allowed: bool = p_body.comph().call_comp("Interactions", &"get_allowed")
	if !allowed:
		return false
	
	if p_body.comph().has_comp("Cutscene"):
		var in_cutscene: bool = p_body.comph().call_comp("Cutscene", &"is_in_cutscene")
		var disabled_by_cutscene: bool = p_body.comph().call_comp("Cutscene", &"is_disabled_by_cutscene")
		if in_cutscene || disabled_by_cutscene:
			return false
	
	var dirs: Array[StringName] = p_area.get_dirs().duplicate()
	var entity_dir: StringName = _a_entity_comph.call_comp("Movement", &"get_dir")
	
	var needs_look_at: bool = p_body.comph().call_comp("Interactions", &"get_needs_look_at")
	if needs_look_at:
		var entity_pos: Variant = _a_entity_comph.call_comp("Interactions", &"get_default_interaction_pos")
		var area_pos: Variant = p_area.get_global_position()
		var face_dir = Global.get_dir_to_pos(entity_pos, area_pos)
		if entity_dir != face_dir:
			return false
	
	if p_area.get_use_dir():
		var body_dir: StringName = p_body.comph().call_comp("Movement", &"get_dir")
		var body_rotation_deg: float = Global.get_dir_rotation_deg(body_dir).y
		for i: int in dirs.size():
			var dir: StringName = dirs[i]
			var rotated_dir: StringName = Global.get_dir_rotated(dir, -body_rotation_deg)
			dirs[i] = rotated_dir
	
	if p_area.get_use_transform():
		var body_rotation_deg: float = p_body.get_global_rotation_degrees().y
		for i: int in dirs.size():
			var dir: StringName = dirs[i]
			var rotated_dir: StringName = Global.get_dir_rotated(dir, -body_rotation_deg)
			dirs[i] = rotated_dir
	
	if !dirs.has(entity_dir):
		return false
	
	return true

func _set_interaction(p_body: Node, p_area: Node) -> void:
	if is_instance_valid(_a_body):
		_a_body.comph().call_comp("Interactions", &"interaction_deactivate", [_a_area])
	if is_instance_valid(p_body):
		var entity_dir: StringName = _a_entity_comph.call_comp("Movement", &"get_dir")
		p_body.comph().call_comp("Interactions", &"interaction_activate", [p_area, entity_dir])
	
	_a_body = p_body
	_a_area = p_area

func get_body() -> Node:
	return _a_body

func get_area() -> Node:
	return _a_area

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass

func _on_Interaction_area_entered(p_area: Node) -> void:
	var interactions_comp: Node = p_area.get_parent()
	var body: Node = interactions_comp.get_entity()
	var type: StringName = p_area.get_type()
	match type:
		&"Walk_In": _a_walk_in[p_area] = body
		&"Press_Key": _a_press_key[p_area] = body

func _on_Interaction_area_exited(p_area: Node) -> void:
	var type: StringName = p_area.get_type()
	match type:
		&"Walk_In": _a_walk_in.erase(p_area)
		&"Press_Key": _a_press_key.erase(p_area)
