extends HBoxContainer
class_name ResultPartyMembers

const _a_ENTRY_SCENE_PATH: String = "res://Global_Scenes/Battle_System/SV_Battle/Result/Party_Members/Entries/%s.tscn"

var _a_entries: Dictionary[StringName, SVResultPartyMemberEntryBase] = {} # Match pm_key to entry instance

func open(p_exp: int) -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var party_members: Dictionary = global_si.get_party_members_active()
	var pm_data: Dictionary[StringName, PartyMemberData]; pm_data.assign(Databases.get_data(&"Party_Members"))
	for pm_key: StringName in party_members:
		var party_member: Dictionary[StringName, Variant]; party_member.assign(party_members[pm_key])
		var pm_args: PartyMemberData = pm_data[pm_key]
		var progress: Dictionary[StringName, Variant]; progress.assign(party_member[&"Progress"])
		var scene: PackedScene = load(_a_ENTRY_SCENE_PATH % pm_key)
		var instance: SVResultPartyMemberEntryBase = scene.instantiate()
		instance.open.call_deferred(pm_args, progress, p_exp)
		
		_a_entries[pm_key] = instance
		add_child(instance)

func close() -> void:
	_a_entries.clear()
	for child: SVResultPartyMemberEntryBase in get_children():
		child.queue_free()
