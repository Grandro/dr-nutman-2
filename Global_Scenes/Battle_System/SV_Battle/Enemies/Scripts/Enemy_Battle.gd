extends SVCharacter
class_name SVEnemy

signal action_reaction_started(p_target: SVPartyMember)
signal action_reaction_finished(p_target: SVPartyMember)

@export var _e_key: StringName = &""
@export var _e_select_offset: Vector3 = Vector3.ZERO

var _a_EXP: int
var _a_loot: Dictionary # [item_key][amount] = amount_in_pool

func _ready() -> void:
	super()
	_a_Actions.reaction_started.connect(_on_Actions_reaction_started)
	_a_Actions.reaction_finished.connect(_on_Actions_reaction_finished)

func _party_members_filtered(p_party_members: Dictionary[StringName, SVPartyMember]) -> Array[StringName]:
	# Filter out dead party members
	var filtered: Array[StringName] = []
	for pm_key: StringName in p_party_members:
		var instance: SVPartyMember = p_party_members[pm_key]
		var HP: int = instance.comph().call_comp("Stats", &"get_curr_stat", [&"HP"])
		if HP > 0:
			filtered.push_back(pm_key)
	
	return filtered

func _pick_target() -> void:
	var party_members: Dictionary[StringName, SVPartyMember] = _a_encounter.get_party_members()
	var filtered: Array[StringName] = _party_members_filtered(party_members)
	var target_key: StringName = filtered.pick_random()
	_a_target = party_members[target_key]

func get_key() -> StringName:
	return _e_key

func get_select_offset() -> Vector3:
	return _e_select_offset

func set_EXP(p_EXP: int) -> void:
	_a_EXP = p_EXP

func get_EXP() -> int:
	return _a_EXP

func set_loot(p_loot: Dictionary) -> void:
	_a_loot = p_loot

func get_loot() -> Dictionary:
	return _a_loot

func _on_Actions_reaction_started() -> void:
	action_reaction_started.emit(_a_target)

func _on_Actions_reaction_finished() -> void:
	action_reaction_finished.emit(_a_target)
