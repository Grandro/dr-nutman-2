extends SVEncounterBase

func _init_party_members():
	super()
	for instance in _a_Party_Members_Instances.get_children():
		instance.comph().call_comp("Display", "set_draw_flag", [Sprite3D.DrawFlags.FLAG_SHADED, false])
