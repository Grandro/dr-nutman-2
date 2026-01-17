extends SVEncounterBase
class_name SVEncounterGhostHouse1

func _init_party_members() -> void:
	super()
	for instance: SVPartyMember in _a_Party_Members_Instances.get_children():
		instance.comph().call_comp("Display", &"set_draw_flag", [Sprite3D.DrawFlags.FLAG_SHADED, false])
