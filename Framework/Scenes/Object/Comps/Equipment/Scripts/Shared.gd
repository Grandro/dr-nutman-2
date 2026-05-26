extends FWExtensionBase
class_name FWCompEquipmentShared

signal equipped(p_group: StringName, p_key: StringName)
signal unequipped(p_group: StringName)

var _a_entity_entity_comph: FWCompHandler

var _a_scenes: Dictionary = {}
var _a_groups: Dictionary[StringName, Node] = {} # Match group to instance
var _a_equipables: Dictionary[StringName, StringName] = {} # Match group to equipable key

func ready() -> void:
	for group_instance: Node in _a_entity.get_children():
		for child: Node in group_instance.get_children():
			child.queue_free()
		
		var group: StringName = group_instance.get_name()
		_a_groups[group] = group_instance
	
	for group: StringName in _a_groups:
		_a_equipables[group] = &""

func init(p_entities: Array[Node]) -> void:
	_a_entity_entity_comph = p_entities[-1].comph()
	
	var anims_comp: FWCompAnims = _a_entity_entity_comph.get_comp("Anims")
	anims_comp.anim_seeked.connect(_on_Anims_anim_seeked)
	anims_comp.anim_stopped.connect(_on_Anims_anim_stopped)
	anims_comp.anim_played.connect(_on_Anims_anim_played)

func play_anim_all(p_name: StringName, p_speed: float, p_backwards: bool) -> void:
	for group_instance: Node in _a_entity.get_children():
		for child: Node in group_instance.get_children():
			child.play_anim(p_name, p_speed, p_backwards)

func seek_anim_all(p_seconds: float, p_update: bool) -> void:
	for group_instance: Node in _a_entity.get_children():
		for child: Node in group_instance.get_children():
			child.seek_anim(p_seconds, p_update)

func stop_anim_all(p_keep_state: bool) -> void:
	for group_instance: Node in _a_entity.get_children():
		for child: Node in group_instance.get_children():
			child.stop_anim(p_keep_state)

func equip_both(p_group: StringName, p_key: StringName) -> void:
	# Can be used for Party_Member and non-Party_Member
	# equip is called by Global if this is Party_Member
	var pm_key: StringName = _get_pm_key()
	if pm_key == &"":
		equip(p_group, p_key)
	else:
		var global_si: Global = Global.get_singleton(_a_entity, "Global")
		global_si.equip_party_member(pm_key, p_group, p_key)

func equip(p_group: StringName, p_key: StringName) -> void:
	if !_a_groups.has(p_group):
		return
	
	var group_instance: Node = _a_groups[p_group]
	for child: Node in group_instance.get_children():
		child.queue_free()
	
	var scene: PackedScene = _a_scenes[p_group][p_key]
	var instance: Node = scene.instantiate()
	instance.set_name(p_key)
	
	_a_equipables[p_group] = p_key
	group_instance.add_child(instance)
	
	_a_entity_entity_comph.call_comp("Anims", &"update_anim")
	equipped.emit(p_group, p_key)

func unequip_both(p_group: StringName) -> void:
	# Can be used for Party_Member and non-Party_Member
	# unequip is called by Global if this is Party_Member
	
	var pm_key: StringName = _get_pm_key()
	if pm_key == &"":
		unequip(p_group)
	else:
		var global_si: Global = Global.get_singleton(_a_entity, "Global")
		global_si.unequip_party_member(pm_key, p_group)

func unequip(p_group: StringName) -> void:
	var group_instance: Node = _a_groups[p_group]
	for child: Node in group_instance.get_children():
		child.queue_free()
	
	_a_equipables[p_group] = &""
	
	_a_entity_entity_comph.call_comp("Anims", &"update_anim")
	unequipped.emit(p_group)

func _update_equipables() -> void:
	for group: StringName in _a_groups:
		_update_equipable(group)

func _update_equipable(p_group: StringName) -> void:
	var key: StringName = _a_equipables[p_group]
	if key != &"":
		equip(p_group, key)

func set_scenes(p_scenes: Dictionary) -> void:
	_a_scenes = p_scenes

func get_scenes() -> Dictionary:
	return _a_scenes

func get_equipable(p_group: StringName) -> StringName:
	return _a_equipables[p_group]

func get_equipables() -> Dictionary[StringName, StringName]:
	return _a_equipables

func get_equipable_instance(p_group: StringName, p_key: String) -> Node:
	var group_instance: Node = _a_groups[p_group]
	var instance: Node = group_instance.get_node(p_key)
	
	return instance

func _get_pm_key() -> StringName:
	var pm_key: StringName = &""
	if _a_entity_entity_comph.has_comp("Party_Member"):
		pm_key = _a_entity_entity_comph.call_comp("Party_Member", &"get_pm_key")
	
	return pm_key

func get_save_data() -> Dictionary[StringName, StringName]:
	return _a_equipables

func load_data(p_data: Dictionary[StringName, StringName]) -> void:
	var pm_key: StringName = _get_pm_key()
	if pm_key == &"":
		_a_equipables = p_data
	else:
		var global_si: Global = Global.get_singleton(_a_entity, "Global")
		for group: StringName in _a_groups:
			var equipable: StringName = global_si.get_party_member_equipable(pm_key, group)
			_a_equipables[group] = equipable
	
	_update_equipables()

func load_data_init() -> void:
	var pm_key: StringName = _get_pm_key()
	if pm_key != &"":
		var global_si: Global = Global.get_singleton(_a_entity, "Global")
		for group: StringName in _a_groups:
			var equipable: StringName = global_si.get_party_member_equipable(pm_key, group)
			_a_equipables[group] = equipable
	
	_update_equipables()

func _on_Anims_anim_seeked(p_seconds: float, p_update: bool) -> void:
	seek_anim_all(p_seconds, p_update)

func _on_Anims_anim_stopped(p_keep_state: bool) -> void:
	stop_anim_all(p_keep_state)

func _on_Anims_anim_played(p_name: StringName) -> void:
	var anim_comp: FWCompAnims = _a_entity_entity_comph.get_comp("Anims")
	var speed: float = anim_comp.get_playing_speed()
	var pos: float = anim_comp.get_current_animation_position()
	var backwards: bool = speed < 0.0
	play_anim_all(p_name, speed, backwards)
	if backwards:
		var length: float = anim_comp.get_current_animation_length()
		if pos < length:
			seek_anim_all(pos, false)
	else:
		if pos > 0.0:
			seek_anim_all(pos, false)
