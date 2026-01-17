extends CompMovementTerrainAreaSharedBase
class_name CompMovementTerrainAreaSharedRigid

var _a_entity_entity: Node
var _a_last_audio_pos: Variant # Vector

func init(p_entity_entity: Node) -> void:
	super(p_entity_entity)
	_a_entity_entity = p_entity_entity
	p_entity_entity.body_entered.connect(_on_Entity_Entity_body_entered)
	
	_a_last_audio_pos = p_entity_entity.get_global_position()

func physics_process() -> void:
	var global_pos: Variant = _a_entity_entity.get_global_position()
	var to_vec: Variant = _a_last_audio_pos - global_pos
	if to_vec.length() < 1.0:
		return
	
	for child: Node in _a_Areas.get_children():
		child.play_audio()
	_a_last_audio_pos = global_pos

func _on_Entity_Entity_body_entered(_p_body: Node) -> void:
	for child: Node in _a_Areas.get_children():
		child.play_audio()
